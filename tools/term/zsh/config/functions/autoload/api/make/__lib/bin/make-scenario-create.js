// make-scenario-create.js
import minimist from 'minimist';
import { scenarioCreate } from '../scenario/scenarioCreate.js';
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
// The content is made of named fields
const {
  _: _positional,
  account,
  'blueprint-file': blueprintFile,
  'scheduling-file': schedulingFile,
  ...options
} = args;
setAccount(account);
const output = await scenarioCreate({
  blueprintFile,
  schedulingFile,
  ...options,
});
console.log(JSON.stringify(output, null, 2));
