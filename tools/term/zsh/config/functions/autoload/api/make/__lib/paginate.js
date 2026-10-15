import { _ } from 'golgoth';

/**
 * Read items page by page. It asks for one item more than the limit, so that
 * the extra item tells whether more items exist, as the API gives no total
 * @param {Function} fetchPage - Called with { offset, limit }, returns an array of items
 * @param {object} options - Pagination options
 * @param {number} options.limit - Maximum number of items, Infinity for all of them
 * @param {number} options.pageSize - Most items the API returns in one page
 * @returns {Promise<object>} The items (at most limit) and hasMore, true when more items exist
 */
export async function paginate(fetchPage, options) {
  const { limit, pageSize } = options;
  const wanted = limit + 1;

  const items = [];
  let isLastPage = false;
  while (!isLastPage && items.length < wanted) {
    const size = Math.min(pageSize, wanted - items.length);
    const page = await fetchPage({ offset: items.length, limit: size });
    items.push(...page);
    // A page shorter than asked is the last one
    isLastPage = page.length < size;
  }

  return {
    items: _.take(items, limit),
    hasMore: items.length > limit,
  };
}
