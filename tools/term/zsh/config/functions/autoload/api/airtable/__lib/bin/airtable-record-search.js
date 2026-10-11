import { airtableRecordSearch } from '../recordSearch.js';

const [base, table, field, text, fieldList, limit] = process.argv.slice(2);

const found = await airtableRecordSearch({
  base,
  table,
  field,
  text,
  fields: fieldList ? fieldList.split(',') : [],
  limit: Number(limit) || undefined,
});
console.log(JSON.stringify(found, null, 2));
