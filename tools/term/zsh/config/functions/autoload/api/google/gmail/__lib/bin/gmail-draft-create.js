// gmail-draft-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { draftCreate } from '../draft/draftCreate.js';

await runBin(async () => {
  // The flags stay strings, so that a missing value is reported by the module
  const { named } = parseBinArgs({
    setAccount,
    minimist: { string: ['messageId', 'to', 'subject', 'body', 'body-file'] },
  });
  const draft = await draftCreate(named);
  console.log(JSON.stringify(draft, null, 2));
});
