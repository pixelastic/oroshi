// make-scenario-run.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { scenarioRun } from '../scenario/scenarioRun.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: {
      string: ['data', 'data-file'],
      boolean: ['wait'],
    },
  });
  const output = await scenarioRun({ scenarioId: positional, ...named });
  // Without --wait the output is the execution ID, with it the full response
  console.log(
    typeof output === 'string' ? output : JSON.stringify(output, null, 2),
  );
});
