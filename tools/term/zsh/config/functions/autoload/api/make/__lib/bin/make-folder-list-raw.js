// make-folder-list-raw.js
import minimist from 'minimist';
import { folderListRaw } from '../folder/folderListRaw.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The filters are named
const { _: _positional, account, ...filters } = args;
setAccount(account);
const output = await folderListRaw(filters);
console.log(output);
