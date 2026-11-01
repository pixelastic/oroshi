// gcal-event-delete.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { eventDelete } from '../event/eventDelete.js';

await runBin(async () => {
  // The id of the Event is the positional argument
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: { string: ['calendarId'] },
  });
  const output = await eventDelete({ eventId: positional, ...named });
  console.log(output);
});
