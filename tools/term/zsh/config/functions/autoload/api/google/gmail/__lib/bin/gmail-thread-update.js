// gmail-thread-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { threadUpdate } from '../thread/threadUpdate.js';

await runBin(async () => {
  // The id of the Thread is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: { boolean: ['read'] },
  });
  const output = await threadUpdate({ threadId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
