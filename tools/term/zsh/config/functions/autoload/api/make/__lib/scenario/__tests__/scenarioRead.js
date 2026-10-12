import { __, scenarioRead } from '../scenarioRead.js';

describe('scenarioRead', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ scenario: { id: 925 } });
    vi.spyOn(__, 'formatScenario').mockReturnValue({ id: 'formatted' });
  });

  it('calls the endpoint of the Scenario id', async () => {
    await scenarioRead({ scenarioId: 925 });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925');
  });

  it('returns the Scenario, formatted', async () => {
    const actual = await scenarioRead({ scenarioId: 925 });

    expect(__.formatScenario).toHaveBeenCalledWith({ id: 925 });
    expect(actual).toEqual({ id: 'formatted' });
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
