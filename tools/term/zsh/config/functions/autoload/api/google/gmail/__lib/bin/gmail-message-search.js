// gmail-message-search.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { messageSearch } from '../message/messageSearch.js';

await runBin(async () => {
  // The Gmail query is the positional argument
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await messageSearch({ query: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
