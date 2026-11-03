// gmail-label-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { labelListRaw } from '../label/labelListRaw.js';

await runBin(async () => {
  // The filter on the name is the positional argument
  const { positional } = parseBinArgs({ setAccount });
  const output = await labelListRaw({ query: positional });
  console.log(output);
});
