// make-scenario-update.js
import minimist from 'minimist';
import { scenarioUpdate } from '../scenario/scenarioUpdate.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2), {
  string: [
    'name',
    'blueprint',
    'blueprint-file',
    'scheduling',
    'scheduling-file',
  ],
});
// The id is the positional argument, the content is made of named fields
const {
  _: [scenarioId],
  account,
  'blueprint-file': blueprintFile,
  'scheduling-file': schedulingFile,
  ...options
} = args;
setAccount(account);
const output = await scenarioUpdate({
  scenarioId,
  blueprintFile,
  schedulingFile,
  ...options,
});
console.log(JSON.stringify(output, null, 2));
