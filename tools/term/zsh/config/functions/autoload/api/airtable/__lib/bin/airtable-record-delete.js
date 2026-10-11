// airtable-record-delete.js
import minimist from 'minimist';
import { recordDelete } from '../record/recordDelete.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The id is the positional argument, the anchors are named
const {
  _: [recordId],
  account,
  ...options
} = args;
setAccount(account);
const output = await recordDelete({ recordId, ...options });
console.log(output);
