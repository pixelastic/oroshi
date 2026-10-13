// notion-page-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { pageListRaw } from '../page/pageListRaw.js';
import { setAccount } from '../setAccount.js';

// The id of the parent page is the positional argument
const { positional, named } = parseBinArgs({ setAccount });
const output = await pageListRaw({ pageId: positional, ...named });
console.log(output);
