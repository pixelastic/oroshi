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

describe('executionRead arguments', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ scenarioLog: {} });
    vi.spyOn(__, 'formatExecution').mockReturnValue({});
  });

  it.each([
    {
      title: 'MAKE_SCENARIO_ID_MISSING without scenarioId',
      input: { executionId: 'cfcf' },
      code: 'MAKE_SCENARIO_ID_MISSING',
      expected:
        'Missing --scenarioId, the Scenario ID is named. Usage: make-execution-read <executionId> --scenarioId <scenarioId>',
    },
    {
      title: 'MAKE_EXECUTION_ID_MISSING without executionId',
      input: { scenarioId: 925 },
      code: 'MAKE_EXECUTION_ID_MISSING',
      expected:
        'Missing the Execution ID, it is positional. Usage: make-execution-read <executionId> --scenarioId <scenarioId>',
    },
  ])('throws $title', async ({ input, code, expected }) => {
    let actual = null;
    try {
      await executionRead(input);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', code);
    expect(actual).toHaveProperty('message', expected);
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
