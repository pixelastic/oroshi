// gmail-thread-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { threadListRaw } from '../thread/threadListRaw.js';

await runBin(async () => {
  const { named } = parseBinArgs({ setAccount });
  const output = await threadListRaw(named);
  console.log(output);
});
