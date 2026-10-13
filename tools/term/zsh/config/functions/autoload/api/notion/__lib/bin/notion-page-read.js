// notion-page-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { pageRead } from '../page/pageRead.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument
const { positional, named } = parseBinArgs({ setAccount });
const output = await pageRead({ pageId: positional, ...named });
console.log(JSON.stringify(output, null, 2));
