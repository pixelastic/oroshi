// make-scenario-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { scenarioCreate } from '../scenario/scenarioCreate.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The content is made of named fields
  const { named } = parseBinArgs({
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
  const output = await scenarioCreate(named);
  console.log(JSON.stringify(output, null, 2));
});
