// notion-page-remove.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { pageRemove } from '../page/pageRemove.js';
import { setAccount } from '../setAccount.js';

// The passage is named. It stays a string, even when it looks like a number
const { named } = parseBinArgs({
  setAccount,
  minimist: { string: ['old', 'old-file'] },
});
const output = await pageRemove(named);
console.log(JSON.stringify(output, null, 2));
