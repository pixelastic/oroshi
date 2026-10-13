// notion-icon-generate.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { iconGenerate } from '../icon/iconGenerate.js';
import { setAccount } from '../setAccount.js';

// The id is a named argument, as the Icon has no id of its own
const { named } = parseBinArgs({
  setAccount,
  minimist: { boolean: ['force', 'recursive'] },
});
const output = await iconGenerate(named);
console.log(JSON.stringify(output, null, 2));
