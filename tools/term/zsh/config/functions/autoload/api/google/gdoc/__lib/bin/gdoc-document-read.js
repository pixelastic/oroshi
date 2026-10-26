// gdoc-document-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { documentRead } from '../document/documentRead.js';

await runBin(async () => {
  // The URL or id is the positional argument
  const { positional } = parseBinArgs({ setAccount });
  const output = await documentRead({ documentId: positional });
  console.log(JSON.stringify(output, null, 2));
});
