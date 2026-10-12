// make-scenario-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { scenarioRead } from '../scenario/scenarioRead.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument
const { positional, named } = parseBinArgs({ setAccount });
const output = await scenarioRead({ scenarioId: positional, ...named });
console.log(JSON.stringify(output, null, 2));
