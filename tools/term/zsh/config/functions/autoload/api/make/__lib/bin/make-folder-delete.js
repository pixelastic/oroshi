// make-folder-delete.js
import minimist from 'minimist';
import { folderDelete } from '../folder/folderDelete.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The id is the positional argument
const {
  _: [folderId],
  account,
  ...options
} = args;
setAccount(account);
const output = await folderDelete({ folderId, ...options });
console.log(output);
