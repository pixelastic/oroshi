import { __, executionListRaw } from '../executionListRaw.js';

describe('executionListRaw', () => {
  beforeEach(() => {
    vi.spyOn(__, 'executionSearch').mockReturnValue({
      results: [
        {
          id: 'cfcf',
          status: 3,
          type: 'auto',
          timestamp: '2026-10-12T09:46:06.720Z',
          duration: 190,
          operations: 0,
        },
        { id: '7985', type: 'stop', timestamp: '2026-10-12T09:46:07.585Z' },
      ],
      hasMore: false,
    });
    vi.spyOn(console, 'error').mockReturnValue();
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
    __.executionSearch.mockReturnValue({ results: [], hasMore: false });

    const actual = await executionListRaw({ scenarioId: 925 });

    expect(actual).toEqual('');
  });

  it('warns that more results exist, and still prints the lines', async () => {
    __.executionSearch.mockReturnValue({
      results: [{ id: 'cfcf' }],
      hasMore: true,
    });

    const actual = await executionListRaw({ scenarioId: 925 });

    expect(console.error).toHaveBeenCalledWith(
      'More results exist, raise --limit',
    );
    expect(actual).toEqual('cfcf▮▮▮▮▮');
  });

  it('does not warn when no more results exist', async () => {
    await executionListRaw({ scenarioId: 925 });

    expect(console.error).not.toHaveBeenCalled();
  });
});

describe('executionListRaw arguments', () => {
  it('throws MAKE_SCENARIO_ID_MISSING without scenarioId, with no search', async () => {
    vi.spyOn(__, 'executionSearch').mockReturnValue({
      results: [],
      hasMore: false,
    });

    let actual = null;
    try {
      await executionListRaw({ status: 'error' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_SCENARIO_ID_MISSING');
    expect(actual).toHaveProperty(
      'message',
      'Missing the Scenario ID. Usage: make-execution-list --scenarioId <scenarioId> [--status <status>]',
    );
    expect(__.executionSearch).not.toHaveBeenCalled();
  });
});
