// gmail-message-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { messageListRaw } from '../message/messageListRaw.js';

await runBin(async () => {
  const { named } = parseBinArgs({ setAccount });
  const output = await messageListRaw(named);
  console.log(output);
});
