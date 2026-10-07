import { airtableAttachmentRemove } from '../attachmentRemove.js';

const [base, table, record, field, ...attachments] = process.argv.slice(2);

// The wrapper sends either --all or a list of Attachment IDs
const all = attachments[0] === '--all';

await airtableAttachmentRemove({
  base,
  table,
  record,
  field,
  attachments: all ? [] : attachments,
  all,
});
