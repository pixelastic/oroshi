// circleci-project-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { projectRead } from '../project/projectRead.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The slug is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {},
  });
  const output = await projectRead({ projectSlug: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
