// gmail-attachment-remove.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { attachmentRemove } from '../attachment/attachmentRemove.js';

await runBin(async () => {
  const { named } = parseBinArgs({
    setAccount,
    options: {
      draftId: { type: 'string' },
      partId: { type: 'string' },
    },
  });
  const draft = await attachmentRemove(named);
  console.log(JSON.stringify(draft, null, 2));
});
