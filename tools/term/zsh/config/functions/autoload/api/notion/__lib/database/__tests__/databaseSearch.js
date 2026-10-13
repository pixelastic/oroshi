import { _ } from 'golgoth';
import { __, databaseSearch } from '../databaseSearch.js';

describe('databaseSearch', () => {
  // Pages of results, chained by cursor, so that a page is served by the
  // cursor the module sends. Like the API, a page holds at most page_size items
  const mockPages = (pages) => {
    vi.spyOn(__, 'callApi').mockImplementation((path, options) => {
      const cursor = options.body.start_cursor;
      const index = cursor ? Number(cursor.replace('cursor', '')) : 0;
      const results = _.chain(pages[index])
        .take(options.body.page_size)
        .map((id) => ({
          object: 'data_source',
          id: `source-${id}`,
          parent: { type: 'database_id', database_id: id },
        }))
        .value();
      const hasMore = index + 1 < pages.length;
      return {
        results,
        has_more: hasMore,
        next_cursor: hasMore ? `cursor${index + 1}` : null,
      };
    });
  };
  const ids = (count, prefix = 'db') =>
    _.times(count, (index) => `${prefix}${index}`);

  beforeEach(() => {
    vi.spyOn(__, 'formatDatabase').mockImplementation((database) => ({
      id: database.id,
      formatted: true,
    }));
  });

  it('searches the titles of the workspace for Databases only', async () => {
    mockPages([ids(1)]);

    await databaseSearch({ query: 'meetup', limit: 10 });

    expect(__.callApi).toHaveBeenCalledWith('search', {
      method: 'POST',
      body: {
        query: 'meetup',
        filter: { property: 'object', value: 'data_source' },
        page_size: 10,
      },
    });
  });

  it('returns the formatted Databases, identified by their own id', async () => {
    mockPages([ids(2)]);

    const actual = await databaseSearch({ query: 'meetup' });

    expect(__.formatDatabase).toHaveBeenCalledWith(
      expect.objectContaining({ id: 'db0' }),
    );
    expect(actual).toEqual([
      { id: 'db0', formatted: true },
      { id: 'db1', formatted: true },
    ]);
  });

  it('follows the cursor across pages until the limit is reached', async () => {
    mockPages([ids(100, 'a'), ids(100, 'b'), ids(100, 'c')]);

    const actual = await databaseSearch({ query: 'meetup', limit: 250 });

    expect(actual).toHaveLength(250);
    expect(_.map(__.callApi.mock.calls, '[1].body.start_cursor')).toEqual([
      undefined,
      'cursor1',
      'cursor2',
    ]);
    expect(_.map(__.callApi.mock.calls, '[1].body.page_size')).toEqual([
      100, 100, 50,
    ]);
  });

  it('stops when the API has no more results, even below the limit', async () => {
    mockPages([ids(100, 'a'), ids(20, 'b')]);

    const actual = await databaseSearch({ query: 'meetup', limit: 500 });

    expect(actual).toHaveLength(120);
    expect(__.callApi).toHaveBeenCalledTimes(2);
  });

  it('defaults the limit to 25', async () => {
    mockPages([ids(100)]);

    const actual = await databaseSearch({ query: 'meetup' });

    expect(__).toHaveProperty('callApi.mock.calls.0.1.body.page_size', 25);
    expect(actual).toHaveLength(25);
  });

  it('returns an empty array when nothing matches', async () => {
    mockPages([[]]);

    const actual = await databaseSearch({ query: 'nothing' });

    expect(actual).toEqual([]);
  });
});
