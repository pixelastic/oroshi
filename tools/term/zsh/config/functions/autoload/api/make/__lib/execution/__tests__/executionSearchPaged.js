import { _ } from 'golgoth';
import { __, executionSearchPaged } from '../executionSearchPaged.js';

describe('executionSearchPaged', () => {
  /**
   * Get the query of the first call to the API
   * @returns {object} The query
   */
  function sentQuery() {
    const [, { query }] = __.callApi.mock.calls[0];
    return query;
  }

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      scenarioLogs: [{ id: 'a' }, { id: 'b' }],
    });
    vi.spyOn(__, 'formatExecution').mockImplementation((execution) => ({
      id: execution.id,
      formatted: true,
    }));
  });

  it('sends the Scenario id in the path', async () => {
    await executionSearchPaged({ scenarioId: 925 });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/logs', {
      query: expect.any(Object),
    });
  });

  it.each([
    { input: 'success', expected: 1 },
    { input: 'warning', expected: 2 },
    { input: 'error', expected: 3 },
  ])('converts the status $input to $expected', async ({ input, expected }) => {
    await executionSearchPaged({ scenarioId: 925, status: input });

    expect(sentQuery()).toHaveProperty('status', expected);
  });

  it('does not send a status by default', async () => {
    await executionSearchPaged({ scenarioId: 925 });

    expect(sentQuery().status).toBeUndefined();
  });

  it('throws MAKE_INVALID_STATUS on an unknown status', async () => {
    let actual = null;
    try {
      await executionSearchPaged({ scenarioId: 925, status: 'broken' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_INVALID_STATUS');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it.each([
    {
      title: 'a full ISO date to milliseconds',
      input: '2026-10-12T09:46:06.720Z',
      expected: 1791798366720,
    },
    {
      title: 'a date without time to midnight UTC',
      input: '2026-10-12',
      expected: 1791763200000,
    },
  ])('converts $title', async ({ input, expected }) => {
    await executionSearchPaged({ scenarioId: 925, dateMin: input });

    expect(sentQuery()).toHaveProperty('from', expected);
  });

  it('throws MAKE_INVALID_DATE on an invalid date', async () => {
    let actual = null;
    try {
      await executionSearchPaged({ scenarioId: 925, dateMax: 'yesterday-ish' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_INVALID_DATE');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('sends the date min as from and the date max as to', async () => {
    await executionSearchPaged({
      scenarioId: 925,
      dateMin: '2026-10-12',
      dateMax: '2026-10-13',
    });

    expect(sentQuery()).toMatchObject({
      from: 1791763200000,
      to: 1791849600000,
    });
  });

  it.each([
    {
      title: 'the limit plus one as pg[limit]',
      input: { limit: 10 },
      expected: 11,
    },
    { title: '26 by default', input: {}, expected: 26 },
  ])('sends $title', async ({ input, expected }) => {
    await executionSearchPaged({ scenarioId: 925, ...input });

    expect(sentQuery()).toHaveProperty(['pg[limit]'], expected);
    expect(sentQuery()).toHaveProperty(['pg[offset]'], 0);
  });

  it('follows the offset, with pages of 50 at most', async () => {
    __.callApi.mockImplementation((path, { query }) => ({
      scenarioLogs: _.times(query['pg[limit]'], (index) => ({ id: index })),
    }));

    await executionSearchPaged({ scenarioId: 925, limit: 100 });

    const queries = _.map(__.callApi.mock.calls, ([, { query }]) => query);
    expect(queries).toEqual([
      { 'pg[limit]': 50, 'pg[offset]': 0 },
      { 'pg[limit]': 50, 'pg[offset]': 50 },
      { 'pg[limit]': 1, 'pg[offset]': 100 },
    ]);
  });

  it.each([
    {
      title: 'all Executions, with hasMore false when all arrived',
      input: {},
      expected: {
        executions: [
          { id: 'a', formatted: true },
          { id: 'b', formatted: true },
        ],
        hasMore: false,
      },
    },
    {
      title: 'no more than the limit, with hasMore true when more exist',
      input: { limit: 1 },
      expected: { executions: [{ id: 'a', formatted: true }], hasMore: true },
    },
  ])('returns $title', async ({ input, expected }) => {
    const actual = await executionSearchPaged({ scenarioId: 925, ...input });

    expect(actual).toEqual(expected);
  });
});

describe('executionSearchPaged arguments', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ scenarioLogs: [] });
  });

  it('throws MAKE_SCENARIO_ID_MISSING without scenarioId, with no API call', async () => {
    let actual = null;
    try {
      await executionSearchPaged({ status: 'error' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_SCENARIO_ID_MISSING');
    expect(actual).toHaveProperty(
      'message',
      'Missing --scenarioId, the Scenario ID is named. Usage: make-execution-search --scenarioId <scenarioId> [--status <status>]',
    );
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
