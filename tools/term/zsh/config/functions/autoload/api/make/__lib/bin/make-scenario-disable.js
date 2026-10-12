// make-scenario-disable.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { scenarioDisable } from '../scenario/scenarioDisable.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument
const { positional, named } = parseBinArgs({ setAccount });
const output = await scenarioDisable({ scenarioId: positional, ...named });
console.log(JSON.stringify(output, null, 2));
