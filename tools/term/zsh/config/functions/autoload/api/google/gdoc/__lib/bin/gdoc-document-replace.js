// gdoc-document-replace.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { documentReplace } from '../document/documentReplace.js';

await runBin(async () => {
  // The Document URL or id is the positional argument. The passages are named,
  // and stay strings even when they look like numbers
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      old: { type: 'string' },
      'old-file': { type: 'string' },
      new: { type: 'string' },
      'new-file': { type: 'string' },
    },
  });
  const output = await documentReplace({ documentId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
