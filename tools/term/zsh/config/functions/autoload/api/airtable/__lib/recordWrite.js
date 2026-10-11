import { callApi } from './callApi.js';

export let __;

/**
 * Create a Record, or update the given one, and return its ID. An update leaves
 * the Fields that are not given untouched
 * @param {object} options - Write options
 * @param {string} options.base - Base ID
 * @param {string} options.table - Table name
 * @param {string} [options.record] - Record ID to update. A new Record is created without it
 * @param {object} options.fields - Regular Fields to set, never Attachments
 * @returns {Promise<string>} The ID of the Record
 */
export async function airtableRecordWrite(options) {
  const { base, table, record, fields } = options;

  const tablePath = `${base}/${encodeURIComponent(table)}`;
  const response = await __.callApi(
    record ? `${tablePath}/${record}` : tablePath,
    {
      method: record ? 'PATCH' : 'POST',
      body: { fields },
    },
  );

  return response.id;
}

__ = { callApi };
