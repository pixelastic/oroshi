// gdoc-comment-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { commentListRaw } from '../comment/commentListRaw.js';

await runBin(async () => {
  // The URL or id is the positional argument
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await commentListRaw({ documentId: positional, ...named });
  console.log(output);
});
