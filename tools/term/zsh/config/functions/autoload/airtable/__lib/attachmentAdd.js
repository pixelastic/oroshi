import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { _ } from 'golgoth';
import { firostError, isFile } from 'firost';
import { airtableApi } from './api.js';

const MAX_FILE_SIZE = 5 * 1024 * 1024;

/**
 * Upload a local file into a Field of type Attachment, and return the ID of
 * the new Attachment. Airtable appends it and keeps the existing Attachments
 * @param {object} options - Upload options
 * @param {string} options.base - Base alias or Base ID
 * @param {string} options.record - Record ID holding the Field
 * @param {string} options.field - Field name or Field ID of type Attachment
 * @param {string} options.file - Path of the local file, 5 MB at most
 * @param {string} options.contentType - Content type of the file
 * @returns {Promise<string>} The ID of the new Attachment
 */
export async function airtableAttachmentAdd(options) {
  const { base, record, field, file, contentType } = options;

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
  const response = await airtableApi({
    mode: 'write',
    method: 'POST',
    host: 'content',
    base,
    path: [record, field, 'uploadAttachment'],
    body: {
      contentType,
      filename: path.basename(file),
      file: content.toString('base64'),
    },
  });

  // The response lists every Attachment of the Field, the new one comes last
  const attachments = _.chain(response.fields).values().first().value();
  return _.last(attachments).id;
}
