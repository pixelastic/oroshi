import { _ } from 'golgoth';
import { firostError } from 'firost';
import { __, recordSearch } from '../recordSearch.js';

describe('recordSearch', () => {
  const anchors = { baseId: 'appDEVREL', tableId: 'tblMEETUPS' };

  // Pages of Records, chained by offset, so that a page is served by the
  // offset the module sends. Like the API, a page holds at most pageSize Records
  const mockPages = (pages) => {
    vi.spyOn(__, 'callApi').mockImplementation((path, options) => {
      const index = options.query.offset
        ? Number(options.query.offset.replace('page', ''))
        : 0;
      const records = _.chain(pages[index])
        .take(options.query.pageSize)
        .map((id) => ({
          id,
          fields: { Name: id },
        }))
        .value();
      return index + 1 < pages.length
        ? { records, offset: `page${index + 1}` }
        : { records };
    });
  };
  const ids = (count, prefix = 'rec') =>
    _.times(count, (index) => `${prefix}${index}`);

  beforeEach(() => {
    vi.spyOn(__, 'formatRecord').mockImplementation((record) => ({
      id: record.id,
      formatted: true,
    }));
  });

  it('sends the formula and the anchors to the API', async () => {
    mockPages([ids(1)]);

    await recordSearch({ ...anchors, query: "{Name}='Paris'", limit: 10 });

    expect(__.callApi).toHaveBeenCalledWith('appDEVREL/tblMEETUPS', {
      query: { filterByFormula: "{Name}='Paris'", pageSize: 11 },
    });
  });

  it('encodes a Table name in the path', async () => {
    mockPages([ids(1)]);

    await recordSearch({ baseId: 'appDEVREL', tableId: 'My Meetups' });

    expect(__.callApi).toHaveBeenCalledWith(
      'appDEVREL/My%20Meetups',
      expect.anything(),
    );
  });

  it('sends no formula when the query is empty', async () => {
    mockPages([ids(1)]);

    await recordSearch({ ...anchors, query: '' });

    const { query } = __.callApi.mock.calls[0][1];
    expect(query.filterByFormula).toBeUndefined();
  });

  it('returns the formatted Records of one page', async () => {
    mockPages([ids(3)]);

    const actual = await recordSearch({ ...anchors, limit: 10 });

    expect(actual).toEqual({
      results: [
        { id: 'rec0', formatted: true },
        { id: 'rec1', formatted: true },
        { id: 'rec2', formatted: true },
      ],
      hasMore: false,
    });
    expect(__.callApi).toHaveBeenCalledTimes(1);
  });

  it('follows the offset across pages until the limit is reached', async () => {
    mockPages([ids(100, 'a'), ids(100, 'b'), ids(100, 'c')]);

    const actual = await recordSearch({ ...anchors, limit: 250 });

    expect(actual.results).toHaveLength(250);
    expect(__.callApi).toHaveBeenCalledTimes(3);
    expect(_.map(__.callApi.mock.calls, '[1].query.offset')).toEqual([
      undefined,
      'page1',
      'page2',
    ]);
  });

  it('asks for one Record more than the limit, in pages of at most 100', async () => {
    mockPages([ids(100, 'a'), ids(100, 'b'), ids(100, 'c')]);

    await recordSearch({ ...anchors, limit: 250 });

    expect(_.map(__.callApi.mock.calls, '[1].query.pageSize')).toEqual([
      100, 100, 51,
    ]);
  });

  it('stops when the API returns no more offset, even below the limit', async () => {
    mockPages([ids(100, 'a'), ids(20, 'b')]);

    const actual = await recordSearch({ ...anchors, limit: 500 });

    expect(actual.results).toHaveLength(120);
    expect(__.callApi).toHaveBeenCalledTimes(2);
  });

  it('returns no Record when nothing matches', async () => {
    mockPages([[]]);

    const actual = await recordSearch({ ...anchors, query: "{Name}='x'" });

    expect(actual).toEqual({ results: [], hasMore: false });
  });

  it('defaults the limit to 25', async () => {
    mockPages([ids(100)]);

    const actual = await recordSearch(anchors);

    expect(__).toHaveProperty('callApi.mock.calls.0.1.query.pageSize', 26);
    expect(actual.results).toHaveLength(25);
  });

  it('reports more results when the extra Record arrived', async () => {
    mockPages([ids(100, 'a'), ids(100, 'b'), ids(100, 'c')]);

    const actual = await recordSearch({ ...anchors, limit: 250 });

    expect(actual).toHaveProperty('hasMore', true);
    expect(actual.results).toHaveLength(250);
  });

  it.each([
    { title: 'fewer Records than the limit', count: 40, limit: 100 },
    { title: 'exactly as many Records as the limit', count: 100, limit: 100 },
  ])('reports no more results with $title', async ({ count, limit }) => {
    mockPages([ids(count)]);

    const actual = await recordSearch({ ...anchors, limit });

    expect(actual).toHaveProperty('hasMore', false);
    expect(actual.results).toHaveLength(count);
  });

  it.each([
    {
      title: 'Base',
      options: { tableId: 'tblA' },
      code: 'AIRTABLE_BASE_ID_MISSING',
    },
    {
      title: 'Table',
      options: { baseId: 'appA' },
      code: 'AIRTABLE_TABLE_ID_MISSING',
    },
  ])('throws when the $title is missing', async ({ options, code }) => {
    mockPages([ids(1)]);

    let actual = null;
    try {
      await recordSearch(options);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', code);
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('surfaces the failure of the API', async () => {
    vi.spyOn(__, 'callApi').mockImplementation(() => {
      throw firostError('AIRTABLE_REQUEST_FAILED', 'INVALID_FILTER_BY_FORMULA');
    });

    let actual = null;
    try {
      await recordSearch({ ...anchors, query: '(' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_REQUEST_FAILED');
  });
});
