import { __, executionListRaw } from '../executionListRaw.js';

describe('executionListRaw', () => {
  beforeEach(() => {
    vi.spyOn(__, 'executionSearchPaged').mockReturnValue({
      executions: [
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
    vi.spyOn(__, 'warnMoreResults').mockReturnValue();
  });

  it('searches with the flags it received', async () => {
    await executionListRaw({ scenarioId: 925, status: 'error' });

    expect(__.executionSearchPaged).toHaveBeenCalledWith({
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
    __.executionSearchPaged.mockReturnValue({ executions: [], hasMore: false });

    const actual = await executionListRaw({ scenarioId: 925 });

    expect(actual).toEqual('');
  });

  it('warns that more results exist, and still prints the lines', async () => {
    __.executionSearchPaged.mockReturnValue({
      executions: [{ id: 'cfcf' }],
      hasMore: true,
    });

    const actual = await executionListRaw({ scenarioId: 925 });

    expect(__.warnMoreResults).toHaveBeenCalledTimes(1);
    expect(actual).toEqual('cfcf▮▮▮▮▮');
  });

  it('does not warn when no more results exist', async () => {
    await executionListRaw({ scenarioId: 925 });

    expect(__.warnMoreResults).not.toHaveBeenCalled();
  });
});

describe('executionListRaw arguments', () => {
  it('throws MAKE_SCENARIO_ID_MISSING without scenarioId, with no search', async () => {
    vi.spyOn(__, 'executionSearchPaged').mockReturnValue({
      executions: [],
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
      'Missing --scenarioId, the Scenario ID is named. Usage: make-execution-list --scenarioId <scenarioId> [--status <status>]',
    );
    expect(__.executionSearchPaged).not.toHaveBeenCalled();
  });
});
