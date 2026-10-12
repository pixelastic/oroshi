import { __, scenarioDelete } from '../scenarioDelete.js';

describe('scenarioDelete', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue('');
  });

  it('calls the endpoint of the Scenario id with DELETE', async () => {
    await scenarioDelete({ scenarioId: 925 });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925', {
      method: 'DELETE',
    });
  });

  it('returns the id', async () => {
    const actual = await scenarioDelete({ scenarioId: 925 });

    expect(actual).toEqual(925);
  });
});
