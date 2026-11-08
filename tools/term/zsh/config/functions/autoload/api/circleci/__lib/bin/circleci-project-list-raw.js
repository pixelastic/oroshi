// circleci-project-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { projectListRaw } from '../project/projectListRaw.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The query is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      limit: { type: 'string' },
    },
  });
  const output = await projectListRaw({ query: positional, ...named });
  console.log(output);
});
