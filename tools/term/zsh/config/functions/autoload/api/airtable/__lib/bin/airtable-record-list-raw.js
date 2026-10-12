// airtable-record-list-raw.js
import minimist from 'minimist';
import { recordListRaw } from '../record/recordListRaw.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The formula is the first positional argument, the filters are named
const {
  _: [query],
  account,
  ...filters
} = args;
setAccount(account);
const output = await recordListRaw({ query, ...filters });
console.log(output);
