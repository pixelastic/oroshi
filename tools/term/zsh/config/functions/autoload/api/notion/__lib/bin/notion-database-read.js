// notion-database-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { databaseRead } from '../database/databaseRead.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument
const { positional, named } = parseBinArgs({ setAccount });
const output = await databaseRead({ databaseId: positional, ...named });
console.log(JSON.stringify(output, null, 2));
