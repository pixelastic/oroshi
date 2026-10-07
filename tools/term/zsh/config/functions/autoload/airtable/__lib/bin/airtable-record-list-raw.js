import { _ } from 'golgoth';
import { airtableRecordListRaw } from '../recordListRaw.js';

const [base, table, fieldList, limit, sort] = process.argv.slice(2);

const lines = await airtableRecordListRaw({
  base,
  table,
  fields: fieldList ? fieldList.split(',') : [],
  limit: Number(limit) || undefined,
  sort: sort || undefined,
});
_.each(lines, (line) => console.log(line));
