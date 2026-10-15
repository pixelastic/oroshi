// make-execution-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { executionRead } from '../execution/executionRead.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // Keep the id as text, a hexadecimal id can look like a number
  // The id is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: { string: ['_'] },
  });
  const output = await executionRead({ executionId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
