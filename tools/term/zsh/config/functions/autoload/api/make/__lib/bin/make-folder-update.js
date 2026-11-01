// make-folder-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { folderUpdate } from '../folder/folderUpdate.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id is the positional argument, the content is made of named fields
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      name: { type: 'string' },
      parentFolderId: { type: 'string' },
    },
  });
  const output = await folderUpdate({ folderId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
