// gmail-label-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { labelCreate } from '../label/labelCreate.js';

await runBin(async () => {
  // The name of the label is the positional argument
  const { positional } = parseBinArgs({ setAccount });
  const output = await labelCreate({ name: positional });
  console.log(JSON.stringify(output, null, 2));
});
