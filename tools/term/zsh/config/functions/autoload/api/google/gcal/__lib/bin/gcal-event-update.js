// gcal-event-update.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { eventUpdate } from '../event/eventUpdate.js';

await runBin(async () => {
  // The id of the Event is the positional argument. Every field is a string
  // flag, so that a title like 2026 is not read as a number, and that a bare
  // flag reaches the module as an empty string
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: {
      string: [
        'title',
        'date-start',
        'date-end',
        'location',
        'description',
        'description-file',
        'calendarId',
      ],
    },
  });
  const output = await eventUpdate({ eventId: positional, ...named });
  console.log(JSON.stringify(output, null, 2));
});
