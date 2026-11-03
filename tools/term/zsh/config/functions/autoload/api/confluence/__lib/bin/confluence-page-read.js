// confluence-page-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { pageRead } from '../page/pageRead.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id is the positional argument
  const { positional } = parseBinArgs({ setAccount, options: {} });
  const output = await pageRead({ pageId: positional });
  console.log(JSON.stringify(output, null, 2));
});
