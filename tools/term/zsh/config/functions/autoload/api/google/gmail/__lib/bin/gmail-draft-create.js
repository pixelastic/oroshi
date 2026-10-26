// gmail-draft-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { draftCreate } from '../draft/draftCreate.js';

await runBin(async () => {
  // parseBinArgs does not return the account, but the aliases depend on it
  let account = null;
  // The flags stay strings, so that a missing value is reported by the module
  const { named } = parseBinArgs({
    setAccount: (name) => {
      account = name;
      setAccount(name);
    },
    minimist: { string: ['messageId', 'to', 'subject', 'body', 'body-file'] },
  });
  const draft = await draftCreate({ ...named, account });
  console.log(JSON.stringify(draft, null, 2));
});
