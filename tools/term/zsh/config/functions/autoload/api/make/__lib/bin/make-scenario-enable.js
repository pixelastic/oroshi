// make-scenario-enable.js
import minimist from 'minimist';
import { scenarioEnable } from '../scenario/scenarioEnable.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The id is the positional argument
const {
  _: [scenarioId],
  account,
  ...options
} = args;
setAccount(account);
const output = await scenarioEnable({ scenarioId, ...options });
console.log(JSON.stringify(output, null, 2));
