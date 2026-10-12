import { _ } from 'golgoth';
import { recordUpdate } from '../record/recordUpdate.js';
import { attachmentAdd } from './attachmentAdd.js';

export let __;

/**
 * Replace every Attachment of a Field with one local file. The upload comes
 * first, so a failed upload leaves the old Attachments in place
 * @param {object} options - Same options as attachmentAdd
 * @param {string} options.baseId - Base ID
 * @param {string} options.tableId - Table ID or name
 * @param {string} options.recordId - Record ID holding the Field
 * @param {string} options.field - Field name of type Attachment
 * @param {string} options.file - Path of the local file, 5 MB at most
 * @returns {Promise<object>} The updated Record, formatted
 */
export async function attachmentReplace(options) {
  const { baseId, tableId, recordId, field } = options;

  const added = await __.attachmentAdd(options);

  // Airtable puts the new Attachment last in the Field
  const attachments = _.get(added, ['fields', field], []);

  // Nothing to remove when the Field was empty
  if (attachments.length <= 1) {
    return added;
  }
  return await __.recordUpdate({
    baseId,
    tableId,
    recordId,
    content: { [field]: [_.chain(attachments).last().pick('id').value()] },
  });
}

__ = { attachmentAdd, recordUpdate };
