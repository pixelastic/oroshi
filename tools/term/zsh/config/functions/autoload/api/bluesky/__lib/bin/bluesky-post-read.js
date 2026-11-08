// bluesky-post-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { postRead } from '../postRead.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  const { positional } = parseBinArgs({ setAccount, options: {} });
  const output = await postRead({ ref: positional });
  console.log(JSON.stringify(output, null, 2));
});
