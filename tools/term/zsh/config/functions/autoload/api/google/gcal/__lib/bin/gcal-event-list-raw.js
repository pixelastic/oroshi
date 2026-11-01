// gcal-event-list-raw.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { eventListRaw } from '../event/eventListRaw.js';

await runBin(async () => {
  // The dates and the id stay strings, so that the module reports a bad value
  const { named } = parseBinArgs({
    setAccount,
    options: {
      today: { type: 'boolean' },
      week: { type: 'boolean' },
      'date-min': { type: 'string' },
      'date-max': { type: 'string' },
      calendarId: { type: 'string' },
      limit: { type: 'string' },
    },
  });
  const output = await eventListRaw(named);
  console.log(output);
});
