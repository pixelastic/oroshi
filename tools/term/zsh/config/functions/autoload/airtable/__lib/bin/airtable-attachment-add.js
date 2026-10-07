import { airtableAttachmentAdd } from '../attachmentAdd.js';

const [base, record, field, file, contentType] = process.argv.slice(2);

const attachmentId = await airtableAttachmentAdd({
  base,
  record,
  field,
  file,
  contentType,
});
console.log(attachmentId);
