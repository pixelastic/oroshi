// gcal-calendar-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { calendarListRaw } from '../calendar/calendarListRaw.js';

await runBin(async () => {
  const { named } = parseBinArgs({ setAccount });
  const output = await calendarListRaw(named);
  console.log(output);
});
