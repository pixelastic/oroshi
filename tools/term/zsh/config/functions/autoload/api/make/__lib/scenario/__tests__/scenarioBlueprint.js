import { __, scenarioBlueprint } from '../scenarioBlueprint.js';

describe('scenarioBlueprint', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      response: { blueprint: { name: 'Sync', flow: [{ id: 1 }] } },
    });
  });

  it('calls the blueprint endpoint of the Scenario', async () => {
    await scenarioBlueprint({ scenarioId: 925 });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/blueprint');
  });

  it('returns the blueprint, without the response wrapper', async () => {
    const actual = await scenarioBlueprint({ scenarioId: 925 });

    expect(actual).toEqual({ name: 'Sync', flow: [{ id: 1 }] });
  });

  it('throws MAKE_SCENARIO_ID_MISSING without a Scenario ID', async () => {
    let actual = null;
    try {
      await scenarioBlueprint({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_SCENARIO_ID_MISSING');
    expect(actual).toHaveProperty(
      'message',
      'Missing the Scenario ID, it is positional. Usage: make-scenario-blueprint <scenarioId>',
    );
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
