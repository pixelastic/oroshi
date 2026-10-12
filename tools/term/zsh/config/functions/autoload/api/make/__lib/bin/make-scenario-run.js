// make-scenario-run.js
import minimist from 'minimist';
import { scenarioRun } from '../scenario/scenarioRun.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2), {
  string: ['data', 'data-file'],
  boolean: ['wait'],
});
// The id is the positional argument
const {
  _: [scenarioId],
  account,
  'data-file': dataFile,
  ...options
} = args;
setAccount(account);
const output = await scenarioRun({ scenarioId, dataFile, ...options });
// Without --wait the output is the execution ID, with it the full response
console.log(
  typeof output === 'string' ? output : JSON.stringify(output, null, 2),
);
