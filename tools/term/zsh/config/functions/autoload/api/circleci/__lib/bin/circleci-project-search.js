// circleci-project-search.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { projectSearch } from '../project/projectSearch.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The query is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      limit: { type: 'string' },
    },
  });
  const output = await projectSearch({ query: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
