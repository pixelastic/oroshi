import { __, runRead } from '../runRead.js';

describe('runRead', () => {
  const workflow = { id: 'runA', pipeline_id: 'pipeA' };
  const pipeline = { id: 'pipeA' };
  const jobs = { items: [{ name: 'ci' }] };

  beforeEach(() => {
    vi.spyOn(__, 'callApi')
      .mockReturnValueOnce(workflow)
      .mockReturnValueOnce(pipeline)
      .mockReturnValueOnce(jobs);
    vi.spyOn(__, 'formatRun').mockReturnValue({ id: 'formatted' });
  });

  it('calls the workflow, the pipeline and the jobs endpoints', async () => {
    await runRead({ runId: 'runA' });

    expect(__.callApi).toHaveBeenNthCalledWith(1, 'workflow/runA');
    expect(__.callApi).toHaveBeenNthCalledWith(2, 'pipeline/pipeA');
    expect(__.callApi).toHaveBeenNthCalledWith(3, 'workflow/runA/job');
  });

  it('returns the run, formatted', async () => {
    const actual = await runRead({ runId: 'runA' });

    expect(__.formatRun).toHaveBeenCalledWith({
      workflow,
      pipeline,
      jobs: jobs.items,
    });
    expect(actual).toEqual({ id: 'formatted' });
  });

  it.each([
    { title: 'empty', input: '' },
    { title: 'missing', input: undefined },
  ])('throws when the id is $title', async ({ input }) => {
    let actual = null;
    try {
      await runRead({ runId: input });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_MISSING_ARGUMENT');
    expect(actual).toHaveProperty('message', 'Pass the id of the run');
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
