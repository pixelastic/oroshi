// notion-page-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { pageUpdate } from '../page/pageUpdate.js';
import { setAccount } from '../setAccount.js';

// The Properties are the positional argument, the id is named
const { positional, named } = parseBinArgs({ setAccount });
const output = await pageUpdate({ data: positional, ...named });
console.log(JSON.stringify(output, null, 2));
