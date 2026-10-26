// gmail-message-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { messageRead } from '../message/messageRead.js';

await runBin(async () => {
  // The id of the Message is the positional argument
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await messageRead({ messageId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
