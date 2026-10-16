import { __, scenarioRead } from '../scenarioRead.js';

describe('scenarioRead', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockImplementation((path) => {
      if (path === 'scenarios/925/blueprint') {
        return { response: { blueprint: { flow: [{ id: 1 }] } } };
      }
      return { scenario: { id: 925 } };
    });
    vi.spyOn(__, 'formatScenario').mockReturnValue({ id: 'formatted' });
    vi.spyOn(__, 'buildFlow').mockReturnValue([{ id: 'flow' }]);
  });

  it('calls the endpoints of the Scenario and of its blueprint', async () => {
    await scenarioRead({ scenarioId: 925 });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925');
    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/blueprint');
  });

  it('returns the flow of the blueprint with the scenario fields', async () => {
    const actual = await scenarioRead({ scenarioId: 925 });

    expect(__.formatScenario).toHaveBeenCalledWith({ id: 925 });
    expect(__.buildFlow).toHaveBeenCalledWith([{ id: 1 }]);
    expect(actual).toEqual({ id: 'formatted', flow: [{ id: 'flow' }] });
  });

  it('throws MAKE_SCENARIO_ID_MISSING without calling the API', async () => {
    let actual = null;
    try {
      await scenarioRead({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_SCENARIO_ID_MISSING');
    expect(actual.message).toContain('make-scenario-read <scenarioId>');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('lets the error of callApi reach the caller', async () => {
    __.callApi.mockImplementation(() => {
      throw new Error('MAKE_REQUEST_FAILED');
    });

    let actual = null;
    try {
      await scenarioRead({ scenarioId: 925 });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'MAKE_REQUEST_FAILED');
  });
});
