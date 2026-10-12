// airtable-table-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { setAccount } from '../setAccount.js';
import { tableListRaw } from '../table/tableListRaw.js';

const { named } = parseBinArgs({ setAccount });
const output = await tableListRaw(named);
console.log(output);
