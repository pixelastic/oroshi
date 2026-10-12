// make-execution-read.js
import minimist from 'minimist';
import { executionRead } from '../execution/executionRead.js';
import { setAccount } from '../setAccount.js';

// Keep the id as text, a hexadecimal id can look like a number
const args = minimist(process.argv.slice(2), { string: ['_'] });
// The id is the positional argument
const {
  _: [executionId],
  account,
  ...options
} = args;
setAccount(account);
const output = await executionRead({ executionId, ...options });
console.log(JSON.stringify(output, null, 2));
