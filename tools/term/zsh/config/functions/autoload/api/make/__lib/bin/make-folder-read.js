// make-folder-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { folderRead } from '../folder/folderRead.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument
const { positional, named } = parseBinArgs({ setAccount });
const output = await folderRead({ folderId: positional, ...named });
console.log(JSON.stringify(output, null, 2));
