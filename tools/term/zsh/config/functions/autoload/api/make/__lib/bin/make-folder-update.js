// make-folder-update.js
import minimist from 'minimist';
import { folderUpdate } from '../folder/folderUpdate.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2), { string: ['name'] });
// The id is the positional argument, the content is made of named fields
const {
  _: [folderId],
  account,
  ...options
} = args;
setAccount(account);
const output = await folderUpdate({ folderId, ...options });
console.log(JSON.stringify(output, null, 2));
