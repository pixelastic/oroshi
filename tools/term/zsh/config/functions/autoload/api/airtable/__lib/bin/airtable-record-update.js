// airtable-record-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { recordUpdate } from '../record/recordUpdate.js';
import { setAccount } from '../setAccount.js';

// The content is the positional argument (open schema), the id and the
// anchors are named
const { positional, named } = parseBinArgs({ setAccount });
const output = await recordUpdate({ content: positional, ...named });
console.log(JSON.stringify(output, null, 2));
