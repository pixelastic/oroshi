// circleci-run-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { runListRaw } from '../run/runListRaw.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The project is the anchor, so it is named. There is no positional query
  const { named } = parseBinArgs({
    setAccount,
    options: {
      project: { type: 'string' },
      branch: { type: 'string' },
      status: { type: 'string' },
      limit: { type: 'string' },
    },
  });
  const output = await runListRaw(named);
  console.log(output);
});
