// gdoc-document-append.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { documentAppend } from '../document/documentAppend.js';

await runBin(async () => {
  // The Document URL or id is the first positional argument, the inline
  // Markdown is the second
  const {
    _: [documentId, content],
    named,
  } = parseBinArgs({
    setAccount,
    options: {
      'content-file': { type: 'string' },
    },
  });
  const output = await documentAppend({ documentId, content, ...named });
  console.log(JSON.stringify(output, null, 2));
});
