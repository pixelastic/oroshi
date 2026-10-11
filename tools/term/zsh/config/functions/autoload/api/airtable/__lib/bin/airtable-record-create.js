// airtable-record-create.js
import minimist from 'minimist';
import { recordCreate } from '../record/recordCreate.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The content is the positional argument (open schema), the anchors are named
const {
  _: [content],
  'data-file': dataFile,
  account,
  ...options
} = args;
setAccount(account);
const output = await recordCreate({ content, dataFile, ...options });
console.log(JSON.stringify(output, null, 2));
