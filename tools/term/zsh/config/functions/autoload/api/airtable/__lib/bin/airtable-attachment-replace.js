// airtable-attachment-replace.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { attachmentReplace } from '../attachment/attachmentReplace.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  const { named } = parseBinArgs({
    setAccount,
    options: {
      baseId: { type: 'string' },
      tableId: { type: 'string' },
      recordId: { type: 'string' },
      field: { type: 'string' },
      file: { type: 'string' },
    },
  });
  const output = await attachmentReplace(named);
  console.log(JSON.stringify(output, null, 2));
});
