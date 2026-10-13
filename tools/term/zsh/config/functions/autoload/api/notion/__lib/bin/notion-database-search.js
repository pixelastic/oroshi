// notion-database-search.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { databaseSearch } from '../database/databaseSearch.js';
import { setAccount } from '../setAccount.js';

// The text to look for is the positional argument, the options are named
const { positional, named } = parseBinArgs({ setAccount });
const output = await databaseSearch({ query: positional, ...named });
console.log(JSON.stringify(output, null, 2));
