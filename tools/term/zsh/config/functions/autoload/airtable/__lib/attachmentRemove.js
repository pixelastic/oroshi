import { _ } from 'golgoth';
import { firostError } from 'firost';
import { airtableRecordRead } from './recordRead.js';
import { airtableRecordWrite } from './recordWrite.js';

/**
 * Remove Attachments from a Field of type Attachment, by ID. Airtable has no
 * delete call, so the Field is read, then updated with the Attachments to keep.
 * Give either `attachments` or `all`. An ID that is not in the Field throws
 * and changes nothing, unless `all` is set
 * @param {object} options - Remove options
 * @param {string} options.base - Base ID
 * @param {string} options.table - Table name
 * @param {string} options.record - Record ID holding the Field
 * @param {string} options.field - Field name of type Attachment
 * @param {string[]} [options.attachments] - IDs of the Attachments to remove
 * @param {boolean} [options.all] - Remove every Attachment of the Field
 * @returns {Promise<void>}
 */
export async function airtableAttachmentRemove(options) {
  const { base, table, record, field, attachments = [], all = false } = options;

  const fields = await airtableRecordRead({
    base,
    table,
    record,
    fields: [field],
  });
  const currentIds = _.chain(fields).get([field], []).map('id').value();

  // Return early, before any update, if an ID is not in the Field
  const unknownIds = _.difference(attachments, currentIds);
  if (!all && !_.isEmpty(unknownIds)) {
    throw firostError(
      'AIRTABLE_ATTACHMENT_NOT_IN_FIELD',
      `Attachment not in Field ${field}: ${unknownIds.join(', ')}`,
    );
  }

  const keptIds = all ? [] : _.difference(currentIds, attachments);
  await airtableRecordWrite({
    base,
    table,
    record,
    fields: { [field]: _.map(keptIds, (id) => ({ id })) },
  });
}
