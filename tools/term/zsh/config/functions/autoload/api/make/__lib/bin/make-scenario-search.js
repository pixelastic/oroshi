// make-scenario-search.js
import minimist from 'minimist';
import { scenarioSearch } from '../scenario/scenarioSearch.js';
import { setAccount } from '../setAccount.js';

const args = minimist(process.argv.slice(2));
// The text is the first positional argument, the filters are named
const {
  _: [query],
  account,
  ...filters
} = args;
setAccount(account);
const output = await scenarioSearch({ query, ...filters });
console.log(JSON.stringify(output, null, 2));
