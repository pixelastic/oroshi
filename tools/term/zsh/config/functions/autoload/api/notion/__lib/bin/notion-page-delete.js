// notion-page-delete.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { pageDelete } from '../page/pageDelete.js';
import { setAccount } from '../setAccount.js';

// The id is the positional argument
const { positional, named } = parseBinArgs({ setAccount });
const output = await pageDelete({ pageId: positional, ...named });
console.log(output);
