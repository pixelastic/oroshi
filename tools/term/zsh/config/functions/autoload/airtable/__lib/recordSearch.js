import { _ } from 'golgoth';
import { airtableApi } from './api.js';

export let __;

const MAX_PAGE_SIZE = 100;

/**
 * Find the Records whose Field contains a text, ignoring case, with a single
 * API call
 * @param {object} options - Search options
 * @param {string} options.base - Base ID
 * @param {string} options.table - Table name
 * @param {string} options.field - Field to search in
 * @param {string} options.text - Text to look for
 * @param {string[]} [options.fields] - Fields to return, all by default
 * @param {number} [options.limit] - Maximum number of Records, capped at 100
 * @returns {Promise<object[]>} The matching Records, as { id, fields }
 */
export async function airtableRecordSearch(options) {
  const { base, table, field, text, fields = [], limit } = options;

  const response = await airtableApi({
    mode: 'read',
    method: 'GET',
    base,
    path: table,
    query: {
      filterByFormula: __.formula(field, text),
      pageSize: limit && Math.min(limit, MAX_PAGE_SIZE),
      fields,
    },
  });

  return _.map(response.records, (record) => ({
    id: record.id,
    fields: record.fields,
  }));
}

__ = {
  /**
   * Build the formula that matches a Field containing a text, ignoring case
   * @param {string} field - Field name
   * @param {string} text - Text to look for
   * @returns {string} Airtable formula
   */
  formula(field, text) {
    const escapedText = text.replace(/[\\']/g, '\\$&');
    const escapedField = field.replace(/[\\}]/g, '\\$&');
    return `SEARCH(LOWER('${escapedText}'),LOWER({${escapedField}}))`;
  },
};
