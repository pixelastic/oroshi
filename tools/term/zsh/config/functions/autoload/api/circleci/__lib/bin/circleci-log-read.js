// circleci-log-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { logRead } from '../log/logRead.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id of the run is the positional argument. The filters are named
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      job: { type: 'string' },
      status: { type: 'string' },
    },
  });
  const output = await logRead({ runId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
