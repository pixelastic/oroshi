import { __, executionSearch } from '../executionSearch.js';

describe('executionSearch', () => {
  beforeEach(() => {
    vi.spyOn(__, 'executionSearchPaged').mockReturnValue({
      executions: [{ id: 'a' }, { id: 'b' }],
      hasMore: true,
    });
  });

  it('searches with the flags it received', async () => {
    await executionSearch({ scenarioId: 925, status: 'error', limit: 10 });

    expect(__.executionSearchPaged).toHaveBeenCalledWith({
      scenarioId: 925,
      status: 'error',
      limit: 10,
    });
  });

  it('returns the Executions as a plain array', async () => {
    const actual = await executionSearch({ scenarioId: 925 });

    expect(actual).toEqual([{ id: 'a' }, { id: 'b' }]);
  });
});
