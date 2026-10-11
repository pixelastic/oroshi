import { _ } from 'golgoth';
import { airtableBaseListRaw } from '../baseListRaw.js';

const lines = await airtableBaseListRaw();
_.each(lines, (line) => console.log(line));
