// circleci-run-rerun.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { runRerun } from '../run/runRerun.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id of the run is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {},
  });
  const output = await runRerun({ runId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
