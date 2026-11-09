import { __, logRead } from '../logRead.js';

describe('logRead', () => {
  const run = {
    id: 'runA',
    project: 'gh/org/repo',
    createdAt: '2026-01-01T00:00:00Z',
    jobs: [
      { number: 10, name: 'ci' },
      { number: 11, name: 'lint' },
      { number: null, name: 'hold' },
    ],
  };
  const details = {
    'project/gh/org/repo/10': {
      steps: [
        {
          actions: [
            {
              name: 'install',
              status: 'success',
              run_time_millis: 1500,
              output_url: 'https://output/install',
            },
          ],
        },
        {
          actions: [
            {
              name: 'test',
              status: 'failed',
              run_time_millis: 2400,
              output_url: 'https://output/test',
            },
          ],
        },
      ],
    },
    'project/gh/org/repo/11': {
      steps: [
        {
          actions: [
            {
              name: 'eslint',
              status: 'failed',
              run_time_millis: 400,
              output_url: 'https://output/eslint',
            },
          ],
        },
      ],
    },
  };

  beforeEach(() => {
    vi.spyOn(__, 'runRead').mockReturnValue(run);
    vi.spyOn(__, 'callApi').mockImplementation((path) => details[path]);
    vi.spyOn(__, 'downloadOutput').mockImplementation(
      (url) => `output of ${url}`,
    );
  });

  it('reads the run, then the v1.1 detail of each job with a number', async () => {
    await logRead({ runId: 'runA' });

    expect(__.runRead).toHaveBeenCalledWith({ runId: 'runA' });
    expect(__.callApi).toHaveBeenCalledTimes(2);
    expect(__.callApi).toHaveBeenCalledWith('project/gh/org/repo/10', {
      baseUrl: 'https://circleci.com/api/v1.1',
    });
    expect(__.callApi).toHaveBeenCalledWith('project/gh/org/repo/11', {
      baseUrl: 'https://circleci.com/api/v1.1',
    });
  });

  it('returns the run and one entry per step', async () => {
    const actual = await logRead({ runId: 'runA' });

    expect(actual).toEqual({
      id: 'runA',
      project: 'gh/org/repo',
      createdAt: '2026-01-01T00:00:00Z',
      steps: [
        {
          job: 'ci',
          jobNumber: 10,
          name: 'install',
          status: 'success',
          duration: 2,
          output: 'output of https://output/install',
        },
        {
          job: 'ci',
          jobNumber: 10,
          name: 'test',
          status: 'failed',
          duration: 2,
          output: 'output of https://output/test',
        },
        {
          job: 'lint',
          jobNumber: 11,
          name: 'eslint',
          status: 'failed',
          duration: 0,
          output: 'output of https://output/eslint',
        },
      ],
    });
  });

  it('removes the ANSI codes of every output', async () => {
    __.downloadOutput.mockImplementation(() => '\u001b[31mred\u001b[39m text');

    const actual = await logRead({ runId: 'runA' });

    expect(actual).toHaveProperty('steps.0.output', 'red text');
  });

  it('gives a null duration to a step without timing', async () => {
    __.callApi.mockImplementation(() => ({
      steps: [{ actions: [{ name: 'skip', status: 'not_run' }] }],
    }));

    const actual = await logRead({ runId: 'runA' });

    expect(actual.steps[0]).toHaveProperty('duration', null);
  });

  it('downloads only the steps of the status', async () => {
    const actual = await logRead({ runId: 'runA', status: 'failed' });

    expect(__.downloadOutput).toHaveBeenCalledTimes(2);
    expect(__.downloadOutput).not.toHaveBeenCalledWith(
      'https://output/install',
    );
    expect(actual.steps.map((step) => step.name)).toEqual(['test', 'eslint']);
  });

  it('keeps only the steps of the job', async () => {
    const actual = await logRead({ runId: 'runA', job: 'ci' });

    expect(actual.steps.map((step) => step.name)).toEqual(['install', 'test']);
    expect(__.callApi).toHaveBeenCalledTimes(1);
  });

  it('keeps the steps that match both filters', async () => {
    const actual = await logRead({
      runId: 'runA',
      job: 'ci',
      status: 'failed',
    });

    expect(actual.steps.map((step) => step.name)).toEqual(['test']);
  });

  it('gives an empty output to a step without an output URL', async () => {
    __.callApi.mockImplementation(() => ({
      steps: [{ actions: [{ name: 'quiet', status: 'success' }] }],
    }));

    const actual = await logRead({ runId: 'runA', job: 'ci' });

    expect(actual.steps[0]).toHaveProperty('output', '');
    expect(__.downloadOutput).not.toHaveBeenCalled();
  });

  it.each([
    { title: 'empty', input: '' },
    { title: 'missing', input: undefined },
  ])('throws when the id is $title', async ({ input }) => {
    let actual = null;
    try {
      await logRead({ runId: input });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_MISSING_ARGUMENT');
    expect(actual).toHaveProperty('message', 'Pass the id of the run');
    expect(__.runRead).not.toHaveBeenCalled();
  });
});

describe('logRead.downloadOutput', () => {
  it('fetches the URL and joins the text of the messages', async () => {
    const messages = [{ message: 'one\n' }, { message: 'two\n' }];
    vi.spyOn(__, 'fetch').mockReturnValue({
      ok: true,
      json: () => messages,
    });

    const actual = await __.downloadOutput('https://output/a');

    expect(__.fetch).toHaveBeenCalledWith('https://output/a');
    expect(actual).toEqual('one\ntwo\n');
  });

  it('throws when the download fails', async () => {
    vi.spyOn(__, 'fetch').mockReturnValue({ ok: false, status: 403 });

    let actual = null;
    try {
      await __.downloadOutput('https://output/a');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', '403 https://output/a');
  });
});
