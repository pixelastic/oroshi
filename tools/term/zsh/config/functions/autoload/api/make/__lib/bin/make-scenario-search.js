// make-scenario-search.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { scenarioSearch } from '../scenario/scenarioSearch.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The text is the first positional argument, the filters are named
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await scenarioSearch({ query: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
