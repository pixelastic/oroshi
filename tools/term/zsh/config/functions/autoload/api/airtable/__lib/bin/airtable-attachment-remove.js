// airtable-attachment-remove.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { attachmentRemove } from '../attachment/attachmentRemove.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  const { named } = parseBinArgs({
    setAccount,
    minimist: {
      string: ['field', 'attachmentId'],
      boolean: ['all'],
    },
  });
  const output = await attachmentRemove(named);
  console.log(JSON.stringify(output, null, 2));
});
