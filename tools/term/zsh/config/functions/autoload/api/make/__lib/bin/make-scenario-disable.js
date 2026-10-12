// make-scenario-disable.js
import minimist from 'minimist';
import { scenarioDisable } from '../scenario/scenarioDisable.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The id is the positional argument
const {
  _: [scenarioId],
  account,
  ...options
} = args;
setAccount(account);
const output = await scenarioDisable({ scenarioId, ...options });
console.log(JSON.stringify(output, null, 2));
