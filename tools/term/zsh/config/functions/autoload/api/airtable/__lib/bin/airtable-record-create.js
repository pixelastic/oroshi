// airtable-record-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { recordCreate } from '../record/recordCreate.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The content is the positional argument (open schema), the anchors are named
  const { positional, named } = parseBinArgs({ setAccount });
  const output = await recordCreate({ content: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
