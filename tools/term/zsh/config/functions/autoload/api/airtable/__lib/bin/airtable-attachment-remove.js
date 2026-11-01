// airtable-attachment-remove.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { attachmentRemove } from '../attachment/attachmentRemove.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  const { named } = parseBinArgs({
    setAccount,
    options: {
      baseId: { type: 'string' },
      tableId: { type: 'string' },
      recordId: { type: 'string' },
      field: { type: 'string' },
      attachmentId: { type: 'string', multiple: true },
      all: { type: 'boolean' },
    },
  });
  const output = await attachmentRemove(named);
  console.log(JSON.stringify(output, null, 2));
});
