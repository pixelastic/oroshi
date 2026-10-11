// airtable-attachment-remove.js
import minimist from 'minimist';
import { attachmentRemove } from '../attachment/attachmentRemove.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2), {
  string: ['field', 'attachmentId'],
  boolean: ['all'],
});
const { account, ...options } = args;
setAccount(account);
const output = await attachmentRemove(options);
console.log(JSON.stringify(output, null, 2));
