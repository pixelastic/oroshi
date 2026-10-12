// make-execution-search.js
import minimist from 'minimist';
import { executionSearch } from '../execution/executionSearch.js';
import { setAccount } from '../setAccount.js';

// Keep the dates as text, so that a bare year is not read as a number
const args = minimist(process.argv.slice(2), {
  string: ['status', 'date-min', 'date-max'],
});
const { account, 'date-min': dateMin, 'date-max': dateMax, ...options } = args;
setAccount(account);
const output = await executionSearch({ dateMin, dateMax, ...options });
console.log(JSON.stringify(output, null, 2));
