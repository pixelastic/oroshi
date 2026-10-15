import { _ } from 'golgoth';
import { paginate } from '../paginate.js';

describe('paginate', () => {
  /**
   * Fake an API that holds a number of items, and slices them like Make does
   * @param {number} total - Number of items the API holds
   * @returns {Function} The fetchPage mock
   */
  function fakeApi(total) {
    const all = _.range(total);
    return vi.fn(({ offset, limit }) => _.slice(all, offset, offset + limit));
  }

  it('returns the items of one page when the limit is under the cap', async () => {
    const fetchPage = fakeApi(100);

    const { items } = await paginate(fetchPage, { limit: 5, pageSize: 50 });

    expect(items).toEqual([0, 1, 2, 3, 4]);
    expect(fetchPage).toHaveBeenCalledTimes(1);
    expect(fetchPage).toHaveBeenCalledWith({ offset: 0, limit: 6 });
  });

  it('makes several calls when the limit is above the cap', async () => {
    const fetchPage = fakeApi(500);

    const { items } = await paginate(fetchPage, { limit: 120, pageSize: 50 });

    expect(items).toEqual(_.range(120));
    expect(fetchPage).toHaveProperty('mock.calls', [
      [{ offset: 0, limit: 50 }],
      [{ offset: 50, limit: 50 }],
      [{ offset: 100, limit: 21 }],
    ]);
  });

  it('never requests a page larger than the cap', async () => {
    const fetchPage = fakeApi(500);

    await paginate(fetchPage, { limit: 300, pageSize: 50 });

    const sizes = _.map(fetchPage.mock.calls, ([{ limit }]) => limit);
    expect(_.max(sizes)).toEqual(50);
  });

  it('returns exactly limit items when more exist', async () => {
    const fetchPage = fakeApi(500);

    const { items } = await paginate(fetchPage, { limit: 60, pageSize: 50 });

    expect(items).toHaveLength(60);
  });

  it.each([
    { title: 'true when the extra item arrived', total: 500, expected: true },
    {
      title: 'false with fewer items than the limit',
      total: 3,
      expected: false,
    },
    {
      title: 'false with exactly as many items as the limit',
      total: 60,
      expected: false,
    },
  ])('reports hasMore $title', async ({ total, expected }) => {
    const fetchPage = fakeApi(total);

    const { hasMore } = await paginate(fetchPage, { limit: 60, pageSize: 50 });

    expect(hasMore).toEqual(expected);
  });

  it('stops after a short page', async () => {
    const fetchPage = fakeApi(70);

    const { items, hasMore } = await paginate(fetchPage, {
      limit: 500,
      pageSize: 50,
    });

    expect(items).toHaveLength(70);
    expect(hasMore).toEqual(false);
    expect(fetchPage).toHaveBeenCalledTimes(2);
  });

  it('reads everything with an infinite limit', async () => {
    const fetchPage = fakeApi(120);

    const { items, hasMore } = await paginate(fetchPage, {
      limit: Infinity,
      pageSize: 50,
    });

    expect(items).toHaveLength(120);
    expect(hasMore).toEqual(false);
  });
});
