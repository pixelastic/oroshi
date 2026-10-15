// make-execution-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { executionListRaw } from '../execution/executionListRaw.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // Keep the dates as text, so that a bare year is not read as a number
  const { named } = parseBinArgs({
    setAccount,
    minimist: { string: ['status', 'date-min', 'date-max'] },
  });
  const output = await executionListRaw(named);
  console.log(output);
});
