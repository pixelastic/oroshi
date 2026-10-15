// make-scenario-delete.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { scenarioDelete } from '../scenario/scenarioDelete.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id is the positional argument
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await scenarioDelete({ scenarioId: positional, ...named });
  console.log(output);
});
