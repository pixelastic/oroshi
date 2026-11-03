// confluence-page-search.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { pageSearch } from '../page/pageSearch.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The text is the first positional argument, the limit is named
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      limit: { type: 'string' },
    },
  });
  const output = await pageSearch({ query: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
