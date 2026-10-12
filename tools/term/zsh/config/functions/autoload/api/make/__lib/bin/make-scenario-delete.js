// make-scenario-delete.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { scenarioDelete } from '../scenario/scenarioDelete.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument
const { positional, named } = parseBinArgs({ setAccount });
const output = await scenarioDelete({ scenarioId: positional, ...named });
console.log(output);
