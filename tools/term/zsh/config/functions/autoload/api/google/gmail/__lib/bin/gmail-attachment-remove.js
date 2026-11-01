// gmail-attachment-remove.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { attachmentRemove } from '../attachment/attachmentRemove.js';

await runBin(async () => {
  // The flags stay strings, so that a missing value is reported by the module
  const { named } = parseBinArgs({
    setAccount,
    minimist: { string: ['draftId', 'partId'] },
  });
  const draft = await attachmentRemove(named);
  console.log(JSON.stringify(draft, null, 2));
});
