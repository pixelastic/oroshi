// notion-icon-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { iconRead } from '../icon/iconRead.js';
import { setAccount } from '../setAccount.js';

// The id is a named argument, as the Icon has no id of its own
const { named } = parseBinArgs({ setAccount });
const output = await iconRead(named);
console.log(output);
