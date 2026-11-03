// gmail-label-detach.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { labelDetach } from '../label/labelDetach.js';

await runBin(async () => {
  // The name of the label is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      threadId: { type: 'string' },
    },
  });
  const output = await labelDetach({ name: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
