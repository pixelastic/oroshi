// gdoc-document-delete.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { documentDelete } from '../document/documentDelete.js';

await runBin(async () => {
  // The URL or id is the positional argument
  const { positional } = parseBinArgs({
    setAccount,
    options: {},
  });
  const output = await documentDelete({ documentId: positional });
  console.log(JSON.stringify(output, null, 2));
});
