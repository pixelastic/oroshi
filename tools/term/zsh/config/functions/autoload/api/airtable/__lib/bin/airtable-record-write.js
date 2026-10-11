import { airtableRecordWrite } from '../recordWrite.js';

const [base, table, fieldsJson, record] = process.argv.slice(2);

const recordId = await airtableRecordWrite({
  base,
  table,
  record: record || undefined,
  fields: JSON.parse(fieldsJson),
});
console.log(recordId);
