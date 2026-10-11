// airtable-base-list-raw.js
import minimist from 'minimist';
import { baseListRaw } from '../base/baseListRaw.js';
import { setAccount } from '../setAccount.js';

const { _: _positional, account, ...filters } = minimist(process.argv.slice(2));
setAccount(account);
const output = await baseListRaw(filters);
console.log(output);
