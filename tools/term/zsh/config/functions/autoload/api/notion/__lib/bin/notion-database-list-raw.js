// notion-database-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { databaseListRaw } from '../database/databaseListRaw.js';
import { setAccount } from '../setAccount.js';

// The id of the database is the positional argument
const { positional, named } = parseBinArgs({
  setAccount,
  options: {
    filter: { type: 'string' },
    sort: { type: 'string' },
    limit: { type: 'string' },
  },
});
const output = await databaseListRaw({ databaseId: positional, ...named });
console.log(output);
