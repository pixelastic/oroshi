// gmail-attachment-add.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { attachmentAdd } from '../attachment/attachmentAdd.js';

await runBin(async () => {
  // The positional arguments are file paths. They stay strings, so that a file
  // named 2024 is not read as a number
  const { _: files, named } = parseBinArgs({
    setAccount,
    options: { draftId: { type: 'string' } },
  });
  const draft = await attachmentAdd({ draftId: named.draftId, files });
  console.log(JSON.stringify(draft, null, 2));
});
