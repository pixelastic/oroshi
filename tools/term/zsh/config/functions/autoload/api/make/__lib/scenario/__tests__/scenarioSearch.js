import { __, scenarioSearch } from '../scenarioSearch.js';

describe('scenarioSearch', () => {
  beforeEach(() => {
    vi.spyOn(__, 'scenarioSearchPaged').mockReturnValue({
      scenarios: [{ id: 1 }, { id: 2 }],
      hasMore: true,
    });
  });

  it('searches with the flags it received', async () => {
    await scenarioSearch({ query: 'sync', folderId: 12, limit: 10 });

    expect(__.scenarioSearchPaged).toHaveBeenCalledWith({
      query: 'sync',
      folderId: 12,
      limit: 10,
    });
  });

  it('returns the Scenarios as a plain array', async () => {
    const actual = await scenarioSearch({ query: 'sync' });

    expect(actual).toEqual([{ id: 1 }, { id: 2 }]);
  });

  it('searches without flags', async () => {
    await scenarioSearch();

    expect(__.scenarioSearchPaged).toHaveBeenCalledWith({});
  });
});
