// circleci-run-trigger.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { runTrigger } from '../run/runTrigger.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The project is the anchor, so it is named. There is no positional query
  const { named } = parseBinArgs({
    setAccount,
    options: {
      project: { type: 'string' },
      branch: { type: 'string' },
      parameters: { type: 'string' },
    },
  });
  const output = await runTrigger(named);
  console.log(JSON.stringify(output, null, 2));
});
