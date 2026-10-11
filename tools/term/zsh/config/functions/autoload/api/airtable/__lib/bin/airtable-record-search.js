// airtable-record-search.js
import minimist from 'minimist';
import { recordSearch } from '../record/recordSearch.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The formula is the first positional argument, the filters are named
const {
  _: [query],
  account,
  ...filters
} = args;
setAccount(account);
const output = await recordSearch({ query, ...filters });
console.log(JSON.stringify(output, null, 2));
