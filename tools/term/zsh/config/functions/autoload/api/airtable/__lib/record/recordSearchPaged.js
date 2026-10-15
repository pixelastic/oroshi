import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { formatRecord } from './formatRecord.js';

export let __;

const DEFAULT_LIMIT = 25;
const MAX_PAGE_SIZE = 100;

/**
 * Search the Records of a Table with an Airtable formula, and tell if more
 * exist. It makes one API call per page, and follows the offset until it has
 * one Record more than the limit, or the API has no more Records
 * @param {object} options - Search options
 * @param {string} options.baseId - Base ID. Throws AIRTABLE_BASE_ID_MISSING if empty
 * @param {string} options.tableId - Table ID or name. Throws AIRTABLE_TABLE_ID_MISSING if empty
 * @param {string} [options.query] - Airtable formula, all Records by default
 * @param {number} [options.limit] - Maximum number of Records
 * @returns {Promise<object>} The Records, formatted, and hasMore, true when more Records exist than the limit
 */
export async function recordSearchPaged(options) {
  const { baseId, tableId, query, limit = DEFAULT_LIMIT } = options;

  // Without baseId and tableId, the endpoint would be undefined/undefined
  if (!baseId) {
    throw firostError('AIRTABLE_BASE_ID_MISSING', 'Pass --baseId');
  }
  if (!tableId) {
    throw firostError('AIRTABLE_TABLE_ID_MISSING', 'Pass --tableId');
  }

  const path = `${baseId}/${encodeURIComponent(tableId)}`;
  // The API gives no total nor "more" flag, so one extra Record tells it
  const wanted = limit + 1;
  const records = [];
  let offset;
  do {
    const response = await __.callApi(path, {
      query: {
        filterByFormula: query || undefined,
        pageSize: Math.min(wanted - records.length, MAX_PAGE_SIZE),
        offset,
      },
    });
    records.push(...response.records);
    offset = response.offset;
  } while (offset && records.length < wanted);

  return {
    records: _.chain(records).take(limit).map(__.formatRecord).value(),
    hasMore: records.length > limit,
  };
}

__ = {
  callApi,
  formatRecord,
};
