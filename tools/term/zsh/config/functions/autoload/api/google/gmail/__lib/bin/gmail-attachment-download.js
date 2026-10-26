// gmail-attachment-download.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { attachmentDownload } from '../attachment/attachmentDownload.js';

await runBin(async () => {
  // The id of the Mail is the positional argument. The flags stay strings, so
  // that a missing value is reported by the module
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: { string: ['partId', 'out'] },
  });
  const filepath = await attachmentDownload({ mailId: positional, ...named });
  console.log(filepath);
});
