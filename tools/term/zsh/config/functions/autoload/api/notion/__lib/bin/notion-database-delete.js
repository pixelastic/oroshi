// notion-database-delete.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { databaseDelete } from '../database/databaseDelete.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument
const { positional, named } = parseBinArgs({ setAccount });
const output = await databaseDelete({ databaseId: positional, ...named });
console.log(output);
