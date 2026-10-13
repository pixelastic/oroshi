// notion-database-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { databaseCreate } from '../database/databaseCreate.js';
import { setAccount } from '../setAccount.js';

// The schema is the positional argument, the parent is named
const { positional, named } = parseBinArgs({ setAccount });
const output = await databaseCreate({ data: positional, ...named });
console.log(JSON.stringify(output, null, 2));
