import { __, scenarioDisable } from '../scenarioDisable.js';

describe('scenarioDisable', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      scenario: { id: 925, isActive: false },
    });
    vi.spyOn(__, 'scenarioRead').mockReturnValue({ id: 'formatted' });
  });

  it('calls the stop endpoint of the Scenario id', async () => {
    await scenarioDisable({ scenarioId: 925 });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/stop', {
      method: 'POST',
    });
  });

  it('returns the Scenario, as read would', async () => {
    const actual = await scenarioDisable({ scenarioId: 925 });

    expect(__.scenarioRead).toHaveBeenCalledWith({ scenarioId: 925 });
    expect(actual).toEqual({ id: 'formatted' });
  });
});
