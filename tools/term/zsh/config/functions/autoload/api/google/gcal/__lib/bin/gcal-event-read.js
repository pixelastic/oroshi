// gcal-event-read.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { eventRead } from '../event/eventRead.js';

await runBin(async () => {
  // The id of the Event is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: { string: ['calendarId'] },
  });
  const output = await eventRead({ eventId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
