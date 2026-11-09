import { __, runSearch } from '../runSearch.js';

describe('runSearch', () => {
  // Pipelines and workflows, keyed by the path of their endpoint
  let pages;

  /**
   * Answer the API from the pages, an empty page for an unknown path
   * @param {string} path - Path of the endpoint
   * @param {object} [options] - Options of the call
   * @returns {object} The page of the API
   */
  function answer(path, options = {}) {
    const key = options.query?.['page-token']
      ? `${path}?${options.query['page-token']}`
      : path;
    return pages[key] ?? { items: [] };
  }

  /**
   * Get the ids of the runs returned by the search
   * @param {object} [options] - Options of the search
   * @returns {Promise<string[]>} The ids
   */
  async function searchIds(options = {}) {
    const actual = await runSearch({ project: 'gh/o/r', ...options });
    return actual.map((run) => run.id);
  }

  beforeEach(() => {
    pages = {
      'project/gh/o/r/pipeline': {
        items: [
          { id: 'pipeA', number: 2 },
          { id: 'pipeB', number: 1 },
        ],
      },
      'pipeline/pipeA/workflow': {
        items: [{ id: 'runA1', status: 'failed' }],
      },
      'pipeline/pipeB/workflow': {
        items: [
          { id: 'runB1', status: 'success' },
          { id: 'runB2', status: 'failed' },
        ],
      },
    };
    vi.spyOn(__, 'callApi').mockImplementation(answer);
    vi.spyOn(__, 'formatRun').mockImplementation(({ workflow }) => ({
      id: workflow.id,
      status: workflow.status,
      jobs: [],
    }));
  });

  it.each([
    { title: 'lists the pipelines of the project', input: {}, expected: {} },
    {
      title: 'passes the branch to the pipelines call',
      input: { branch: 'renovate/tooling' },
      expected: { branch: 'renovate/tooling' },
    },
  ])('$title', async ({ input, expected }) => {
    await runSearch({ project: 'gh/o/r', ...input });

    expect(__.callApi).toHaveBeenCalledWith('project/gh/o/r/pipeline', {
      query: expected,
    });
  });

  it('lists the workflows of each pipeline', async () => {
    await runSearch({ project: 'gh/o/r' });

    expect(__.callApi).toHaveBeenCalledWith('pipeline/pipeA/workflow');
    expect(__.callApi).toHaveBeenCalledWith('pipeline/pipeB/workflow');
  });

  it('returns one run per workflow, several for one pipeline', async () => {
    const actual = await searchIds();

    expect(actual).toEqual(['runA1', 'runB1', 'runB2']);
  });

  it('formats each run with its workflow and its pipeline, without jobs', async () => {
    const actual = await runSearch({ project: 'gh/o/r', limit: 1 });

    expect(__.formatRun).toHaveBeenCalledWith({
      workflow: { id: 'runA1', status: 'failed' },
      pipeline: { id: 'pipeA', number: 2 },
    });
    expect(actual).toEqual([{ id: 'runA1', status: 'failed' }]);
  });

  it.each([
    { title: 'a number', input: 2 },
    { title: 'a string', input: '2' },
  ])('stops after the limit given as $title', async ({ input }) => {
    const actual = await searchIds({ limit: input });

    expect(actual).toEqual(['runA1', 'runB1']);
  });

  it('does not read the workflows of the pipelines beyond the limit', async () => {
    await searchIds({ limit: 1 });

    expect(__.callApi).not.toHaveBeenCalledWith('pipeline/pipeB/workflow');
  });

  it('follows the cursor of CircleCI across pages up to the limit', async () => {
    pages['project/gh/o/r/pipeline'].next_page_token = 'tok2';
    pages['project/gh/o/r/pipeline?tok2'] = {
      items: [{ id: 'pipeC', number: 0 }],
      next_page_token: 'tok3',
    };
    pages['pipeline/pipeC/workflow'] = { items: [{ id: 'runC1' }] };

    const actual = await searchIds({ limit: 4 });

    expect(actual).toEqual(['runA1', 'runB1', 'runB2', 'runC1']);
    expect(__.callApi).toHaveBeenCalledWith('project/gh/o/r/pipeline', {
      query: { 'page-token': 'tok2' },
    });
    expect(__.callApi).not.toHaveBeenCalledWith(
      'project/gh/o/r/pipeline',
      expect.objectContaining({ query: { 'page-token': 'tok3' } }),
    );
  });

  it('keeps the branch when it follows the cursor', async () => {
    pages['project/gh/o/r/pipeline'].next_page_token = 'tok2';

    await searchIds({ branch: 'main', limit: 10 });

    expect(__.callApi).toHaveBeenCalledWith('project/gh/o/r/pipeline', {
      query: { branch: 'main', 'page-token': 'tok2' },
    });
  });

  it('keeps only the runs of the status, after the limit', async () => {
    const all = await searchIds({ status: 'failed' });
    const limited = await searchIds({ status: 'failed', limit: 2 });

    expect(all).toEqual(['runA1', 'runB2']);
    expect(limited).toEqual(['runA1']);
  });

  it('returns no run for a project without pipeline', async () => {
    pages['project/gh/o/r/pipeline'] = { items: [] };

    const actual = await searchIds();

    expect(actual).toEqual([]);
  });

  it.each([
    { title: 'empty', input: '' },
    { title: 'missing', input: undefined },
  ])('throws when the project is $title', async ({ input }) => {
    let actual = null;
    try {
      await runSearch({ project: input });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_MISSING_ARGUMENT');
    expect(actual).toHaveProperty(
      'message',
      'Pass the project with --project <slug>',
    );
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('throws on an invalid limit, with no call', async () => {
    let actual = null;
    try {
      await runSearch({ project: 'gh/o/r', limit: 'ten' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_INVALID_ARGUMENT');
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
