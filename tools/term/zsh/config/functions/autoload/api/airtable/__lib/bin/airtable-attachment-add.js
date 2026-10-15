// airtable-attachment-add.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { attachmentAdd } from '../attachment/attachmentAdd.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  const { named } = parseBinArgs({
    setAccount,
    minimist: { string: ['field'] },
  });
  const output = await attachmentAdd(named);
  console.log(JSON.stringify(output, null, 2));
});
