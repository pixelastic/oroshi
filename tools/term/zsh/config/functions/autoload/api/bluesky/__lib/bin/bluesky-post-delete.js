// bluesky-post-delete.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { postDelete } from '../postDelete.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  const { positional } = parseBinArgs({ setAccount, options: {} });
  const output = await postDelete({ ref: positional });
  console.log(JSON.stringify(output, null, 2));
});
