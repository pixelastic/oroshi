// make-folder-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { folderCreate } from '../folder/folderCreate.js';
import { setAccount } from '../setAccount.js';

// The content is made of named fields
const { named } = parseBinArgs({
  setAccount,
  minimist: { string: ['name'] },
});
const output = await folderCreate(named);
console.log(JSON.stringify(output, null, 2));
