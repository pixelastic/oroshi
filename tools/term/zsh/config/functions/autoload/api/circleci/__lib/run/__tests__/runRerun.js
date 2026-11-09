import { firostError } from 'firost';
import { __, runRerun } from '../runRerun.js';

describe('runRerun', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ workflow_id: 'runB' });
    vi.spyOn(__, 'runRead').mockReturnValue({ id: 'runB', jobs: [] });
  });

  it('sends a POST to the rerun endpoint of the run', async () => {
    await runRerun({ runId: 'runA' });

    expect(__.callApi).toHaveBeenCalledWith('workflow/runA/rerun', {
      method: 'POST',
      body: {},
    });
  });

  it('returns the new run, read like run-read', async () => {
    const actual = await runRerun({ runId: 'runA' });

    expect(__.runRead).toHaveBeenCalledWith({ runId: 'runB' });
    expect(actual).toEqual({ id: 'runB', jobs: [] });
  });

  it.each([
    { title: 'empty', input: '' },
    { title: 'missing', input: undefined },
  ])('throws when the id is $title', async ({ input }) => {
    let actual = null;
    try {
      await runRerun({ runId: input });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_MISSING_ARGUMENT');
    expect(actual).toHaveProperty('message', 'Pass the id of the run');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('lets a failed call through as a request error', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('CIRCLECI_REQUEST_FAILED', '404 Not found');
    });

    let actual = null;
    try {
      await runRerun({ runId: 'runA' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_REQUEST_FAILED');
    expect(__.runRead).not.toHaveBeenCalled();
  });
});
