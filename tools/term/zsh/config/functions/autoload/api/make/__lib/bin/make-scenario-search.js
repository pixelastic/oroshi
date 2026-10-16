// make-scenario-search.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { scenarioSearch } from '../scenario/scenarioSearch.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The text is the first positional argument, the filters are named
  const { positional, named } = parseBinArgs({ setAccount });
  const { results, hasMore } = await scenarioSearch({
    query: positional,
    ...named,
  });
  if (hasMore) {
    console.error('More results exist, raise --limit');
  }
  console.log(JSON.stringify(results, null, 2));
});
