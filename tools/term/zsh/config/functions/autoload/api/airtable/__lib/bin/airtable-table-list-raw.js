import { _ } from 'golgoth';
import { airtableTableListRaw } from '../tableListRaw.js';

const [base] = process.argv.slice(2);

const lines = await airtableTableListRaw({ base });
_.each(lines, (line) => console.log(line));
