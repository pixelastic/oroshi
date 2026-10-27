// gmail-thread-search.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { threadSearch } from '../thread/threadSearch.js';

await runBin(async () => {
  // The Gmail query is the positional argument
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await threadSearch({ query: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
