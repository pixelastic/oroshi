// airtable-record-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { recordListRaw } from '../record/recordListRaw.js';
import { setAccount } from '../setAccount.js';

// The formula is the first positional argument, the filters are named
const { positional, named } = parseBinArgs({ setAccount });
const output = await recordListRaw({ query: positional, ...named });
console.log(output);
