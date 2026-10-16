// airtable-record-search.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { recordSearch } from '../record/recordSearch.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The formula is the first positional argument, the filters are named
  const { positional, named } = parseBinArgs({ setAccount });
  const { results, hasMore } = await recordSearch({
    query: positional,
    ...named,
  });
  if (hasMore) {
    console.error('More results exist, raise --limit');
  }
  console.log(JSON.stringify(results, null, 2));
});
