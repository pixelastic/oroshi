// notion-icon-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { iconUpdate } from '../icon/iconUpdate.js';
import { setAccount } from '../setAccount.js';

// The Icon is the positional argument, the id is named
const { positional, named } = parseBinArgs({ setAccount });
const output = await iconUpdate({ icon: positional, ...named });
console.log(output);
