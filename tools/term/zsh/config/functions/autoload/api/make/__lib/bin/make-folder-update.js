// make-folder-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { folderUpdate } from '../folder/folderUpdate.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id is the positional argument, the content is made of named fields
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: { string: ['name'] },
  });
  const output = await folderUpdate({ folderId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
