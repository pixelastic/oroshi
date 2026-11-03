// gmail-thread-trash.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { threadTrash } from '../thread/threadTrash.js';

await runBin(async () => {
  // The id of the Thread is the positional argument
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await threadTrash({ threadId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
