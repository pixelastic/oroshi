import { __, executionSearch } from '../executionSearch.js';

describe('executionSearch', () => {
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
    await executionSearch({ scenarioId: 925 });

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/logs', {
      query: expect.any(Object),
    });
  });

  it.each([
    { input: 'success', expected: 1 },
    { input: 'warning', expected: 2 },
    { input: 'error', expected: 3 },
  ])('converts the status $input to $expected', async ({ input, expected }) => {
    await executionSearch({ scenarioId: 925, status: input });

    expect(sentQuery()).toHaveProperty('status', expected);
  });

  it('does not send a status by default', async () => {
    await executionSearch({ scenarioId: 925 });

    expect(sentQuery().status).toBeUndefined();
  });

  it('throws MAKE_INVALID_STATUS on an unknown status', async () => {
    let actual = null;
    try {
      await executionSearch({ scenarioId: 925, status: 'broken' });
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
    await executionSearch({ scenarioId: 925, dateMin: input });

    expect(sentQuery()).toHaveProperty('from', expected);
  });

  it('throws MAKE_INVALID_DATE on an invalid date', async () => {
    let actual = null;
    try {
      await executionSearch({ scenarioId: 925, dateMax: 'yesterday-ish' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_INVALID_DATE');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('sends the date min as from and the date max as to', async () => {
    await executionSearch({
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
    { title: 'the limit as pg[limit]', input: { limit: 10 }, expected: 10 },
    { title: '25 by default', input: {}, expected: 25 },
  ])('sends $title', async ({ input, expected }) => {
    await executionSearch({ scenarioId: 925, ...input });

    expect(sentQuery()).toHaveProperty(['pg[limit]'], expected);
  });

  it('returns the executions, formatted', async () => {
    const actual = await executionSearch({ scenarioId: 925 });

    expect(actual).toEqual([
      { id: 'a', formatted: true },
      { id: 'b', formatted: true },
    ]);
  });
});
