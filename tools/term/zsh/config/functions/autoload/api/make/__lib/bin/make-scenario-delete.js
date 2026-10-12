// make-scenario-delete.js
import minimist from 'minimist';
import { scenarioDelete } from '../scenario/scenarioDelete.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The id is the positional argument
const {
  _: [scenarioId],
  account,
  ...options
} = args;
setAccount(account);
const output = await scenarioDelete({ scenarioId, ...options });
console.log(output);
