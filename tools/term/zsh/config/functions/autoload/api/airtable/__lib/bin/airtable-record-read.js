// airtable-record-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { recordRead } from '../record/recordRead.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument, the anchors are named
const { positional, named } = parseBinArgs({ setAccount });
const output = await recordRead({ recordId: positional, ...named });
console.log(JSON.stringify(output, null, 2));
