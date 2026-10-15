// airtable-base-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { baseListRaw } from '../base/baseListRaw.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  const { named } = parseBinArgs({ setAccount });
  const output = await baseListRaw(named);
  console.log(output);
});
