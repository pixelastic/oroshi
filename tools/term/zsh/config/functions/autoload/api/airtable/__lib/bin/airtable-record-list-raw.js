// airtable-record-list-raw.js
import minimist from 'minimist';
import { recordListRaw } from '../record/recordListRaw.js';
import { setAccount } from '../setAccount.js';

const { _: _positional, account, ...filters } = minimist(process.argv.slice(2));
setAccount(account);
const output = await recordListRaw(filters);
console.log(output);
