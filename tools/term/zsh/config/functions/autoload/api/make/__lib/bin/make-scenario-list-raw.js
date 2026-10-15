// make-scenario-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { scenarioListRaw } from '../scenario/scenarioListRaw.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The text is the first positional argument, the filters are named
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await scenarioListRaw({ query: positional, ...named });
  console.log(output);
});
