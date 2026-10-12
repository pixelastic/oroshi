// airtable-record-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { recordCreate } from '../record/recordCreate.js';
import { setAccount } from '../setAccount.js';

// The content is the positional argument (open schema), the anchors are named
const { positional, named } = parseBinArgs({ setAccount });
const output = await recordCreate({ content: positional, ...named });
console.log(JSON.stringify(output, null, 2));
