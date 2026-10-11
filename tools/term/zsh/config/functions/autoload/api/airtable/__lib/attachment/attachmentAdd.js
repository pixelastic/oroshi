import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { firostError, isFile } from 'firost';
import { callApi } from '../callApi.js';
import { recordRead } from '../record/recordRead.js';

export let __;

const CONTENT_URL = 'https://content.airtable.com/v0';
const MAX_FILE_SIZE = 5 * 1024 * 1024;

/**
 * Upload a local file into a Field of type Attachment. Airtable appends it and
 * keeps the existing Attachments
 * @param {object} options - Upload options
 * @param {string} options.baseId - Base ID. Throws AIRTABLE_BASE_ID_MISSING if empty
 * @param {string} options.tableId - Table ID or name. Throws AIRTABLE_TABLE_ID_MISSING if empty
 * @param {string} options.recordId - Record ID holding the Field. Throws AIRTABLE_RECORD_ID_MISSING if empty
 * @param {string} options.field - Field name or Field ID of type Attachment. Throws AIRTABLE_FIELD_MISSING if empty
 * @param {string} options.file - Path of the local file, 5 MB at most. Throws AIRTABLE_FILE_MISSING if empty
 * @param {string} options.contentType - Content type of the file
 * @returns {Promise<object>} The Record, formatted, with the new Attachment last in the Field
 */
export async function attachmentAdd(options) {
  const { baseId, tableId, recordId, field, file, contentType } = options;

  // Without these, the endpoint would contain undefined
  if (!baseId) {
    throw firostError('AIRTABLE_BASE_ID_MISSING', 'Pass --baseId');
  }
  if (!tableId) {
    throw firostError('AIRTABLE_TABLE_ID_MISSING', 'Pass --tableId');
  }
  if (!recordId) {
    throw firostError('AIRTABLE_RECORD_ID_MISSING', 'Pass --recordId');
  }
  if (!field) {
    throw firostError('AIRTABLE_FIELD_MISSING', 'Pass --field');
  }
  if (!file) {
    throw firostError('AIRTABLE_FILE_MISSING', 'Pass --file');
  }

  // Return early, before any request, if the file is missing or too large
  if (!(await isFile(file))) {
    throw firostError(
      'AIRTABLE_ATTACHMENT_MISSING_FILE',
      `File not found: ${file}`,
    );
  }
  const { size } = await stat(file);
  if (size > MAX_FILE_SIZE) {
    throw firostError(
      'AIRTABLE_ATTACHMENT_TOO_LARGE',
      `File is larger than 5 MB: ${file}`,
    );
  }

  const content = await readFile(file);
  await __.callApi(
    `${CONTENT_URL}/${baseId}/${recordId}/${encodeURIComponent(field)}/uploadAttachment`,
    {
      method: 'POST',
      body: {
        contentType,
        filename: path.basename(file),
        file: content.toString('base64'),
      },
    },
  );

  // The upload response keys the Fields by ID, so read the Record to print
  // it like every other command
  return await __.recordRead({ baseId, tableId, recordId });
}

__ = { callApi, recordRead };
