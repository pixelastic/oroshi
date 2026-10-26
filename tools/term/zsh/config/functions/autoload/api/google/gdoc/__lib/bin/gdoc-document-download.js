// gdoc-document-download.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { documentDownload } from '../document/documentDownload.js';

await runBin(async () => {
  // The URL or id is the positional argument
  const { positional } = parseBinArgs({ setAccount });
  const output = await documentDownload({ documentId: positional });
  console.log(output);
});
