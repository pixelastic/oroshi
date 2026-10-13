// notion-page-append.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { pageAppend } from '../page/pageAppend.js';
import { setAccount } from '../setAccount.js';

// The Content is the positional argument, the id is named
const { positional, named } = parseBinArgs({
  setAccount,
  minimist: { string: ['content', 'content-file'] },
});
const output = await pageAppend({ content: positional, ...named });
console.log(JSON.stringify(output, null, 2));
