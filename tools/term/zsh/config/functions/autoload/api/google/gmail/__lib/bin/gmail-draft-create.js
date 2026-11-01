// gmail-draft-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { draftCreate } from '../draft/draftCreate.js';

await runBin(async () => {
  // The flags are strings, so that a subject like 2026 is not read as a number
  const { named } = parseBinArgs({
    setAccount,
    options: {
      threadId: { type: 'string' },
      to: { type: 'string' },
      subject: { type: 'string' },
      body: { type: 'string' },
      'body-file': { type: 'string' },
    },
  });
  const draft = await draftCreate(named);
  console.log(JSON.stringify(draft, null, 2));
});
