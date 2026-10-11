// airtable-table-list-raw.js
import minimist from 'minimist';
import { setAccount } from '../setAccount.js';
import { tableListRaw } from '../table/tableListRaw.js';

const { _: _positional, account, ...filters } = minimist(process.argv.slice(2));
setAccount(account);
const output = await tableListRaw(filters);
console.log(output);
