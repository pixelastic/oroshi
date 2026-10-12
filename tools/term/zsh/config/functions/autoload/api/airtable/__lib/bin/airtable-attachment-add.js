// airtable-attachment-add.js
import minimist from 'minimist';
import { attachmentAdd } from '../attachment/attachmentAdd.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2), { string: ['field'] });
const { account, ...options } = args;
setAccount(account);
const output = await attachmentAdd(options);
console.log(JSON.stringify(output, null, 2));
