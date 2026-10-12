// airtable-attachment-replace.js
import minimist from 'minimist';
import { attachmentReplace } from '../attachment/attachmentReplace.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2), { string: ['field'] });
const { account, ...options } = args;
setAccount(account);
const output = await attachmentReplace(options);
console.log(JSON.stringify(output, null, 2));
