// make-scenario-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { scenarioUpdate } from '../scenario/scenarioUpdate.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id is the positional argument, the content is made of named fields
  const { positional, named } = parseBinArgs({
    setAccount,
    options: {
      name: { type: 'string' },
      folderId: { type: 'string' },
      blueprint: { type: 'string' },
      'blueprint-file': { type: 'string' },
      scheduling: { type: 'string' },
      'scheduling-file': { type: 'string' },
    },
  });
  const output = await scenarioUpdate({ scenarioId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
