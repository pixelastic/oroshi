// make-scenario-list-raw.js
import minimist from 'minimist';
import { scenarioListRaw } from '../scenario/scenarioListRaw.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The text is the first positional argument, the filters are named
const {
  _: [query],
  account,
  ...filters
} = args;
setAccount(account);
const output = await scenarioListRaw({ query, ...filters });
console.log(output);
