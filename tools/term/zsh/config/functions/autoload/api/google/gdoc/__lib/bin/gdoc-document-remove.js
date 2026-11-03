// gdoc-document-remove.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { documentReplace } from '../document/documentReplace.js';

await runBin(async () => {
  // The Document URL or id is the positional argument. The passage is named,
  // and stays a string even when it looks like a number
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      old: { type: 'string' },
      'old-file': { type: 'string' },
    },
  });
  // Removing is replacing with nothing
  const output = await documentReplace({
    documentId: positional,
    ...named,
    new: '',
  });
  console.log(JSON.stringify(output, null, 2));
});
