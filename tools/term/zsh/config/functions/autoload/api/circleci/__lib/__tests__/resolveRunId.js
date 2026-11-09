import { __, resolveRunId } from '../resolveRunId.js';

describe('resolveRunId', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      number: 2111,
      latest_workflow: { id: 'runA', name: 'commit' },
    });
  });

  it('returns the id of the latest workflow of the job', async () => {
    const actual = await resolveRunId({
      project: 'gh/org/repo',
      jobNumber: 2111,
    });

    expect(__.callApi).toHaveBeenCalledWith('project/gh/org/repo/job/2111');
    expect(actual).toEqual('runA');
  });

  it('returns a run id unchanged, without a request', async () => {
    const actual = await resolveRunId({ runId: 'runB' });

    expect(actual).toEqual('runB');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('prefers the run id when a job number comes with it', async () => {
    const actual = await resolveRunId({
      project: 'gh/org/repo',
      runId: 'runB',
      jobNumber: 2111,
    });

    expect(actual).toEqual('runB');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('throws when the job has no workflow', async () => {
    __.callApi.mockReturnValue({ number: 2111 });

    let actual = null;
    try {
      await resolveRunId({ project: 'gh/org/repo', jobNumber: 2111 });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_NOT_FOUND');
    expect(actual).toHaveProperty(
      'message',
      'No run found for the job 2111 of gh/org/repo',
    );
  });
});
