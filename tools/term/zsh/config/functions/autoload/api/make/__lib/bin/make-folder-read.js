// make-folder-read.js
import minimist from 'minimist';
import { folderRead } from '../folder/folderRead.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The id is the positional argument
const {
  _: [folderId],
  account,
  ...options
} = args;
setAccount(account);
const output = await folderRead({ folderId, ...options });
console.log(JSON.stringify(output, null, 2));
