// gmail-label-delete.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { labelDelete } from '../label/labelDelete.js';

await runBin(async () => {
  // The name of the label is the positional argument
  const { positional } = parseBinArgs({ setAccount });
  const output = await labelDelete({ name: positional });
  console.log(JSON.stringify(output, null, 2));
});
