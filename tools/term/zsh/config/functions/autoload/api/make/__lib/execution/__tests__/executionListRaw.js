import { __, executionListRaw } from '../executionListRaw.js';

describe('executionListRaw', () => {
  beforeEach(() => {
    vi.spyOn(__, 'executionSearch').mockReturnValue([
      {
        id: 'cfcf',
        status: 3,
        type: 'auto',
        timestamp: '2026-10-12T09:46:06.720Z',
        duration: 190,
        operations: 0,
      },
      { id: '7985', type: 'stop', timestamp: '2026-10-12T09:46:07.585Z' },
    ]);
  });

  it('searches with the flags it received', async () => {
    await executionListRaw({ scenarioId: 925, status: 'error' });

    expect(__.executionSearch).toHaveBeenCalledWith({
      scenarioId: 925,
      status: 'error',
    });
  });

  it('prints one line per Execution, with the id first', async () => {
    const actual = await executionListRaw({ scenarioId: 925 });

    expect(actual).toEqual(
      'cfcf▮3▮auto▮2026-10-12T09:46:06.720Z▮190▮0\n7985▮▮stop▮2026-10-12T09:46:07.585Z▮▮',
    );
  });

  it('prints an empty line for no Execution', async () => {
    __.executionSearch.mockReturnValue([]);

    const actual = await executionListRaw({ scenarioId: 925 });

    expect(actual).toEqual('');
  });
});
