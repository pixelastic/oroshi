// confluence-page-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { pageListRaw } from '../page/pageListRaw.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The text is the first positional argument, the limit is named
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      limit: { type: 'string' },
    },
  });
  const output = await pageListRaw({ query: positional, ...named });
  console.log(output);
});
