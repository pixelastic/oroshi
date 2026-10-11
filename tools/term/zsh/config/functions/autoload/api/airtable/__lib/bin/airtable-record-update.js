// airtable-record-update.js
import minimist from 'minimist';
import { recordUpdate } from '../record/recordUpdate.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The id and the content are positional (open schema), the anchors are named
const {
  _: [recordId, content],
  'data-file': dataFile,
  account,
  ...options
} = args;
setAccount(account);
const output = await recordUpdate({ recordId, content, dataFile, ...options });
console.log(JSON.stringify(output, null, 2));
