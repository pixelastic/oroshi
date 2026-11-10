// bluesky-post-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { postListRaw } from '../postListRaw.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  const { named } = parseBinArgs({
    setAccount,
    options: {
      actor: { type: 'string' },
      limit: { type: 'string' },
    },
  });
  const output = await postListRaw(named);
  console.log(output);
});
