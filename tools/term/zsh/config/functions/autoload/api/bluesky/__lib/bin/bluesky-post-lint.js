// bluesky-post-lint.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { postLint } from '../postLint.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  const { named } = parseBinArgs({
    setAccount,
    options: {
      text: { type: 'string' },
      'text-file': { type: 'string' },
      thread: { type: 'boolean' },
    },
  });
  const violations = await postLint(named);
  console.log(JSON.stringify(violations, null, 2));
});
