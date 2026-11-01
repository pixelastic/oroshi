// gcal-event-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { eventCreate } from '../event/eventCreate.js';

await runBin(async () => {
  // Every field is a flag. They stay strings, so that a title like 2026 is not
  // read as a number, and that the module reports a bad date
  const { named } = parseBinArgs({
    setAccount,
    minimist: {
      string: [
        'title',
        'date-start',
        'date-end',
        'location',
        'description',
        'description-file',
        'attendees',
        'calendarId',
      ],
    },
  });
  const output = await eventCreate(named);
  console.log(JSON.stringify(output, null, 2));
});
