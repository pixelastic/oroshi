import { __, recordSearch } from '../recordSearch.js';

describe('recordSearch', () => {
  beforeEach(() => {
    vi.spyOn(__, 'recordSearchPaged').mockReturnValue({
      records: [{ id: 'recA' }, { id: 'recB' }],
      hasMore: true,
    });
  });

  it('searches with the options it received', async () => {
    await recordSearch({ baseId: 'appDEVREL', tableId: 'tblMEETUPS' });

    expect(__.recordSearchPaged).toHaveBeenCalledWith({
      baseId: 'appDEVREL',
      tableId: 'tblMEETUPS',
    });
  });

  it('returns the Records as a plain array', async () => {
    const actual = await recordSearch({});

    expect(actual).toEqual([{ id: 'recA' }, { id: 'recB' }]);
  });
});
