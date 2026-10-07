import { _ } from 'golgoth';
import { airtableAttachmentAdd } from './attachmentAdd.js';
import { airtableAttachmentRemove } from './attachmentRemove.js';
import { airtableRecordRead } from './recordRead.js';

/**
 * Replace every Attachment of a Field with one local file. The upload comes
 * first, so a failed upload leaves the old Attachments in place
 * @param {object} options - Replace options
 * @param {string} options.base - Base alias or Base ID
 * @param {string} options.table - Table name
 * @param {string} options.record - Record ID holding the Field
 * @param {string} options.field - Field name of type Attachment
 * @param {string} options.file - Path of the local file, 5 MB at most
 * @param {string} options.contentType - Content type of the file
 * @returns {Promise<string>} The ID of the new Attachment
 */
export async function airtableAttachmentReplace(options) {
  const { base, table, record, field, file, contentType } = options;

  const fields = await airtableRecordRead({
    base,
    table,
    record,
    fields: [field],
  });
  const oldIds = _.chain(fields).get([field], []).map('id').value();

  const newId = await airtableAttachmentAdd({
    base,
    record,
    field,
    file,
    contentType,
  });

  // Nothing to remove when the Field was empty
  if (!_.isEmpty(oldIds)) {
    await airtableAttachmentRemove({
      base,
      table,
      record,
      field,
      attachments: oldIds,
    });
  }
  return newId;
}
