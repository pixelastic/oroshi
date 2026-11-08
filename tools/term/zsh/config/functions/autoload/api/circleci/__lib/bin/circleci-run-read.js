// circleci-run-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { runRead } from '../run/runRead.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id of the run is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {},
  });
  const output = await runRead({ runId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
