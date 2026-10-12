// make-folder-delete.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { folderDelete } from '../folder/folderDelete.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument
const { positional, named } = parseBinArgs({ setAccount });
const output = await folderDelete({ folderId: positional, ...named });
console.log(output);
