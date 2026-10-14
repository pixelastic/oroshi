// notion-page-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { pageCreate } from '../page/pageCreate.js';
import { setAccount } from '../setAccount.js';

// The Properties are the positional argument, the parent and the content are named
const { positional, named } = parseBinArgs({
  setAccount,
  minimist: { string: ['content', 'content-file'] },
});
const output = await pageCreate({ data: positional, ...named });
console.log(JSON.stringify(output, null, 2));
