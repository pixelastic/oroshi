// make-folder-search.js
import minimist from 'minimist';
import { folderSearch } from '../folder/folderSearch.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The filters are named
const { _: _positional, account, ...filters } = args;
setAccount(account);
const output = await folderSearch(filters);
console.log(JSON.stringify(output, null, 2));
