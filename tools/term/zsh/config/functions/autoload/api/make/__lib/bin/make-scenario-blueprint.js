// make-scenario-blueprint.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { scenarioBlueprint } from '../scenario/scenarioBlueprint.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id is the positional argument
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await scenarioBlueprint({ scenarioId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
