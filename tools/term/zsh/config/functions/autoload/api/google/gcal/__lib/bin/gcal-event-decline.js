// gcal-event-decline.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { eventRespond } from '../event/eventRespond.js';

await runBin(async () => {
  // The id of the Event is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    options: { calendarId: { type: 'string' } },
  });
  const output = await eventRespond({
    eventId: positional,
    responseStatus: 'declined',
    ...named,
  });
  console.log(JSON.stringify(output, null, 2));
});
