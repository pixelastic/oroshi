// make-folder-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { folderListRaw } from '../folder/folderListRaw.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The filters are named
  const { named } = parseBinArgs({ setAccount });
  const output = await folderListRaw(named);
  console.log(output);
});
