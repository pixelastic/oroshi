// airtable-record-update.js
import minimist from 'minimist';
import { recordUpdate } from '../record/recordUpdate.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The content is the positional argument (open schema), the id and the
// anchors are named
const {
  _: [content],
  'data-file': dataFile,
  account,
  ...options
} = args;
setAccount(account);
const output = await recordUpdate({ content, dataFile, ...options });
console.log(JSON.stringify(output, null, 2));
