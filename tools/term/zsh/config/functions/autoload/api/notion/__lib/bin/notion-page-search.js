// notion-page-search.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { pageSearch } from '../page/pageSearch.js';
import { setAccount } from '../setAccount.js';

// The text to look for is the positional argument, the options are named
const { positional, named } = parseBinArgs({ setAccount });
const output = await pageSearch({ query: positional, ...named });
console.log(JSON.stringify(output, null, 2));
