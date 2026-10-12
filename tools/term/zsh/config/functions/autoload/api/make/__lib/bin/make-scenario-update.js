// make-scenario-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { scenarioUpdate } from '../scenario/scenarioUpdate.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument, the content is made of named fields
const { positional, named } = parseBinArgs({
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
const output = await scenarioUpdate({ scenarioId: positional, ...named });
console.log(JSON.stringify(output, null, 2));
