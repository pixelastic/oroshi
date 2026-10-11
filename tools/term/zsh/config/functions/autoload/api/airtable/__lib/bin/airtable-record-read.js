// airtable-record-read.js
import minimist from 'minimist';
import { recordRead } from '../record/recordRead.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The id is the positional argument, the anchors are named
const {
  _: [recordId],
  account,
  ...options
} = args;
setAccount(account);
const output = await recordRead({ recordId, ...options });
console.log(JSON.stringify(output, null, 2));
