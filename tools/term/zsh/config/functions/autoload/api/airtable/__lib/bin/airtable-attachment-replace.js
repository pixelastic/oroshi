import { airtableAttachmentReplace } from '../attachmentReplace.js';

const [base, table, record, field, file, contentType] = process.argv.slice(2);

const attachmentId = await airtableAttachmentReplace({
  base,
  table,
  record,
  field,
  file,
  contentType,
});
console.log(attachmentId);
