// notion-database-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { databaseUpdate } from '../database/databaseUpdate.js';
import { setAccount } from '../setAccount.js';

// The changes are the positional argument, the id is named
const { positional, named } = parseBinArgs({
  setAccount,
  options: {
    databaseId: { type: 'string' },
    'data-file': { type: 'string' },
  },
});
const output = await databaseUpdate({ data: positional, ...named });
console.log(JSON.stringify(output, null, 2));
