// make-folder-create.js
import minimist from 'minimist';
import { folderCreate } from '../folder/folderCreate.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2), { string: ['name'] });
// The content is made of named fields
const { _: _positional, account, ...options } = args;
setAccount(account);
const output = await folderCreate(options);
console.log(JSON.stringify(output, null, 2));
