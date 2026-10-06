import { _ } from 'golgoth';
import { firostError } from 'firost';
import { airtableApi } from './api.js';

/**
 * Read the Fields of a single Record
 * @param {object} options - Read options
 * @param {string} options.base - Base alias or Base ID
 * @param {string} options.table - Table name
 * @param {string} options.record - Record ID
 * @param {string[]} [options.fields] - Fields to return, all by default
 * @returns {Promise<object>} The Fields of the Record
 */
export async function airtableRecordRead(options) {
  const { base, table, record, fields = [] } = options;

  const query = _.chain(fields)
    .map((field) => `fields[]=${encodeURIComponent(field)}`)
    .unshift(`filterByFormula=${encodeURIComponent(`RECORD_ID()='${record}'`)}`)
    .join('&')
    .value();

  const response = await airtableApi({
    mode: 'read',
    method: 'GET',
    base,
    path: `${encodeURIComponent(table)}?${query}`,
  });

  const found = _.get(response, 'records[0].fields');
  if (!found) {
    throw firostError('AIRTABLE_RECORD_NOT_FOUND', 'Record not found');
  }
  return found;
}
