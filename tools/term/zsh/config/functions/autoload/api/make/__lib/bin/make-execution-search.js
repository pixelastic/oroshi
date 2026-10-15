// make-execution-search.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { executionSearch } from '../execution/executionSearch.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // Keep the dates as text, so that a bare year is not read as a number
  const { named } = parseBinArgs({
    setAccount,
    minimist: { string: ['status', 'date-min', 'date-max'] },
  });
  const output = await executionSearch(named);
  console.log(JSON.stringify(output, null, 2));
});
