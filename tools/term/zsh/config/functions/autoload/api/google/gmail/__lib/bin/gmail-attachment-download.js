// gmail-attachment-download.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { attachmentDownload } from '../attachment/attachmentDownload.js';

await runBin(async () => {
  // The id of the Message is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      partId: { type: 'string' },
      out: { type: 'string' },
    },
  });
  const filepath = await attachmentDownload({
    messageId: positional,
    ...named,
  });
  console.log(filepath);
});
