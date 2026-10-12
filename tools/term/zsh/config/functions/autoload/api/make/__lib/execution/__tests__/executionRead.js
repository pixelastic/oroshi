import { __, executionRead } from '../executionRead.js';

describe('executionRead', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ scenarioLog: { id: 'cfcf' } });
    vi.spyOn(__, 'formatExecution').mockReturnValue({ id: 'formatted' });
  });

  it('calls the endpoint of the Scenario and Execution ids', async () => {
    await executionRead({ scenarioId: 925, executionId: 'cfcf' });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/logs/cfcf');
  });

  it('returns the Execution, formatted', async () => {
    const actual = await executionRead({
      scenarioId: 925,
      executionId: 'cfcf',
    });

    expect(__.formatExecution).toHaveBeenCalledWith({ id: 'cfcf' });
    expect(actual).toEqual({ id: 'formatted' });
  });
});
