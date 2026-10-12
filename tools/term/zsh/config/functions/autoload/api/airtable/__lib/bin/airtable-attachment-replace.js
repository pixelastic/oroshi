// airtable-attachment-replace.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { attachmentReplace } from '../attachment/attachmentReplace.js';
import { setAccount } from '../setAccount.js';

const { named } = parseBinArgs({
  setAccount,
  minimist: { string: ['field'] },
});
const output = await attachmentReplace(named);
console.log(JSON.stringify(output, null, 2));
