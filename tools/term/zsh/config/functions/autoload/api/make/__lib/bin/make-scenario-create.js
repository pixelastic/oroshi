// make-scenario-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { scenarioCreate } from '../scenario/scenarioCreate.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The content is made of named fields
  const { named } = parseBinArgs({
    setAccount,
    minimist: {
      string: [
        'name',
        'blueprint',
        'blueprint-file',
        'scheduling',
        'scheduling-file',
      ],
    },
  });
  const output = await scenarioCreate(named);
  console.log(JSON.stringify(output, null, 2));
});
