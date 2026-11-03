// gmail-label-attach.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { labelAttach } from '../label/labelAttach.js';

await runBin(async () => {
  // The name of the label is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      threadId: { type: 'string' },
    },
  });
  const output = await labelAttach({ name: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
