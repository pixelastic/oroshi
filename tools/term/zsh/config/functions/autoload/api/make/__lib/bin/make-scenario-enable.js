// make-scenario-enable.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { scenarioEnable } from '../scenario/scenarioEnable.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id is the positional argument
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await scenarioEnable({ scenarioId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
