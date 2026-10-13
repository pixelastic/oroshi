// notion-page-replace.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { pageReplace } from '../page/pageReplace.js';
import { setAccount } from '../setAccount.js';

// The passages are named. They stay strings, even when they look like numbers
const { named } = parseBinArgs({
  setAccount,
  minimist: { string: ['old', 'old-file', 'new', 'new-file'] },
});
const output = await pageReplace(named);
console.log(JSON.stringify(output, null, 2));
