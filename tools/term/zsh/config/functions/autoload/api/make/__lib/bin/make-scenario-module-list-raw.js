// make-scenario-module-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { scenarioModuleListRaw } from '../scenario/scenarioModuleListRaw.js';
import { setAccount } from '../setAccount.js';

await runBin(async () => {
  // The id is the positional argument, the days and app are named
  const { positional, named } = parseBinArgs({
    setAccount,
    // Keep the app as text, so that a numeric name is not read as a number
    minimist: { string: ['app'] },
  });
  const output = await scenarioModuleListRaw({
    scenarioId: positional,
    ...named,
  });
  console.log(output);
});
