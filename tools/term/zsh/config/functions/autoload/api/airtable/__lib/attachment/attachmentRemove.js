import { _ } from 'golgoth';
import { firostError } from 'firost';
import { recordRead } from '../record/recordRead.js';
import { recordUpdate } from '../record/recordUpdate.js';

export let __;

/**
 * Remove Attachments from a Field of type Attachment, by ID. Airtable has no
 * delete call, so the Field is read, then updated with the Attachments to keep.
 * Give either `attachmentId` or `all`. An ID that is not in the Field throws
 * and changes nothing
 * @param {object} options - Remove options
 * @param {string} options.baseId - Base ID. Throws AIRTABLE_BASE_ID_MISSING if empty
 * @param {string} options.tableId - Table ID or name. Throws AIRTABLE_TABLE_ID_MISSING if empty
 * @param {string} options.recordId - Record ID holding the Field. Throws AIRTABLE_RECORD_ID_MISSING if empty
 * @param {string} options.field - Field name of type Attachment. Throws AIRTABLE_FIELD_MISSING if empty
 * @param {string|string[]} [options.attachmentId] - ID, or IDs, of the Attachments to remove
 * @param {boolean} [options.all] - Remove every Attachment of the Field
 * @returns {Promise<object>} The updated Record, formatted
 */
export async function attachmentRemove(options) {
  const {
    baseId,
    tableId,
    recordId,
    field,
    attachmentId,
    all = false,
  } = options;
  const attachmentIds = _.chain(attachmentId).castArray().compact().value();

  // Return early, before any call, if the request is incomplete or ambiguous
  if (!field) {
    throw firostError('AIRTABLE_FIELD_MISSING', 'Pass --field');
  }
  if (_.isEmpty(attachmentIds) && !all) {
    throw firostError(
      'AIRTABLE_ATTACHMENT_ID_MISSING',
      'Pass --attachmentId or --all',
    );
  }
  if (!_.isEmpty(attachmentIds) && all) {
    throw firostError(
      'AIRTABLE_ATTACHMENT_ID_CONFLICT',
      '--attachmentId and --all cannot be used together',
    );
  }

  const found = await __.recordRead({ baseId, tableId, recordId });
  const currentIds = _.chain(found)
    .get(['fields', field], [])
    .map('id')
    .value();

  // Return early, before any update, if an ID is not in the Field
  const unknownIds = _.difference(attachmentIds, currentIds);
  if (!_.isEmpty(unknownIds)) {
    throw firostError(
      'AIRTABLE_ATTACHMENT_NOT_IN_FIELD',
      `Attachment not in Field ${field}: ${unknownIds.join(', ')}`,
    );
  }

  const keptIds = all ? [] : _.difference(currentIds, attachmentIds);
  return await __.recordUpdate({
    baseId,
    tableId,
    recordId,
    content: { [field]: _.map(keptIds, (id) => ({ id })) },
  });
}

__ = { recordRead, recordUpdate };
