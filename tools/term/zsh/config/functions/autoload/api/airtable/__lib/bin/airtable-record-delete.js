// airtable-record-delete.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { recordDelete } from '../record/recordDelete.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id is the positional argument, the anchors are named
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await recordDelete({ recordId: positional, ...named });
  console.log(output);
});
