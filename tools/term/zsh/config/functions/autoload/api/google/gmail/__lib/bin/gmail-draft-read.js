// gmail-draft-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { draftRead } from '../draft/draftRead.js';

await runBin(async () => {
  // The id of the Draft is the positional argument
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await draftRead({ draftId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
