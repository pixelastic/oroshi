// gmail-attachment-remove.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { attachmentRemove } from '../attachment/attachmentRemove.js';

await runBin(async () => {
  // The id of the Draft is the positional argument. The flags stay strings, so
  // that a missing value is reported by the module
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: { string: ['partId'] },
  });
  const draft = await attachmentRemove({
    draftId: positional,
    ...named,
  });
  console.log(JSON.stringify(draft, null, 2));
});
