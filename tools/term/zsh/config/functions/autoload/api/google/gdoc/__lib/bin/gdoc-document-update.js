// gdoc-document-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { documentUpdate } from '../document/documentUpdate.js';

await runBin(async () => {
  // The Document URL or id is the first positional argument, the path of the
  // file is the second
  const {
    _: [documentId, filepath],
    named,
  } = parseBinArgs({
    setAccount,
    options: {
      title: { type: 'string' },
    },
  });
  const output = await documentUpdate({ documentId, filepath, ...named });
  console.log(JSON.stringify(output, null, 2));
});
