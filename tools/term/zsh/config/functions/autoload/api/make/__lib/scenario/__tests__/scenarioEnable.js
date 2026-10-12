import { __, scenarioEnable } from '../scenarioEnable.js';

describe('scenarioEnable', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      scenario: { id: 925, isActive: true },
    });
    vi.spyOn(__, 'scenarioRead').mockReturnValue({ id: 'formatted' });
  });

  it('calls the start endpoint of the Scenario id', async () => {
    await scenarioEnable({ scenarioId: 925 });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/start', {
      method: 'POST',
    });
  });

  it('returns the Scenario, as read would', async () => {
    const actual = await scenarioEnable({ scenarioId: 925 });

    expect(__.scenarioRead).toHaveBeenCalledWith({ scenarioId: 925 });
    expect(actual).toEqual({ id: 'formatted' });
  });
});
