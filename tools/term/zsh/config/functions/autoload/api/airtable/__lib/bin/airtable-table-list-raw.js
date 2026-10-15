// airtable-table-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '../setAccount.js';
import { tableListRaw } from '../table/tableListRaw.js';

await runBin(async () => {
  const { named } = parseBinArgs({ setAccount });
  const output = await tableListRaw(named);
  console.log(output);
});
