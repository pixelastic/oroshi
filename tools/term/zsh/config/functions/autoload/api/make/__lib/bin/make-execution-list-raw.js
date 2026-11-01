// make-execution-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { executionListRaw } from '../execution/executionListRaw.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // Keep the dates as text, so that a bare year is not read as a number
  const { named } = parseBinArgs({
    setAccount,
    options: {
      scenarioId: { type: 'string' },
      status: { type: 'string' },
      'date-min': { type: 'string' },
      'date-max': { type: 'string' },
      limit: { type: 'string' },
    },
  });
  const output = await executionListRaw(named);
  console.log(output);
});
