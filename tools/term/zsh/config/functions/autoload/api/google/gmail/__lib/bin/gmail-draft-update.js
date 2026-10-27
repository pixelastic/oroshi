// gmail-draft-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { draftUpdate } from '../draft/draftUpdate.js';

await runBin(async () => {
  // The id of the Draft is the positional argument. The flags stay strings, so
  // that a missing value is reported by the module
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: { string: ['to', 'subject', 'body', 'body-file'] },
  });
  const draft = await draftUpdate({ draftId: positional, ...named });
  console.log(JSON.stringify(draft, null, 2));
});
