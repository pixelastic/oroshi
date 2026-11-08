// bluesky-post-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { postCreate } from '../postCreate.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  const { named } = parseBinArgs({
    setAccount,
    options: {
      text: { type: 'string' },
      'text-file': { type: 'string' },
      'dry-run': { type: 'boolean' },
      'no-embed': { type: 'boolean' },
      'reply-to': { type: 'string' },
    },
  });
  const output = await postCreate(named);
  console.log(JSON.stringify(output, null, 2));
});
