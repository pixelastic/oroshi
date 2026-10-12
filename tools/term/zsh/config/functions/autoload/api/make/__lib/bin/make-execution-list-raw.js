// make-execution-list-raw.js
import minimist from 'minimist';
import { executionListRaw } from '../execution/executionListRaw.js';
import { setAccount } from '../setAccount.js';

// Keep the dates as text, so that a bare year is not read as a number
const args = minimist(process.argv.slice(2), {
  string: ['status', 'date-min', 'date-max'],
});
const { account, 'date-min': dateMin, 'date-max': dateMax, ...options } = args;
setAccount(account);
const output = await executionListRaw({ dateMin, dateMax, ...options });
console.log(output);
