// gmail-attachment-add.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { attachmentAdd } from '../attachment/attachmentAdd.js';

await runBin(async () => {
  // The id of the Draft is the first positional argument, all the others are
  // file paths. The positional arguments stay strings, so that a file named
  // 2024 is not read as a number
  const { _: positional } = parseBinArgs({
    setAccount,
    minimist: { string: ['_'] },
  });
  const [draftId, ...files] = positional;
  const draft = await attachmentAdd({ draftId, files });
  console.log(JSON.stringify(draft, null, 2));
});
