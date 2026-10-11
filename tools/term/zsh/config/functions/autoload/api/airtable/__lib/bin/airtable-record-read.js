import { airtableRecordRead } from '../recordRead.js';

const [base, table, record, fieldList] = process.argv.slice(2);

const found = await airtableRecordRead({
  base,
  table,
  record,
  fields: fieldList ? fieldList.split(',') : [],
});
console.log(JSON.stringify(found, null, 2));
