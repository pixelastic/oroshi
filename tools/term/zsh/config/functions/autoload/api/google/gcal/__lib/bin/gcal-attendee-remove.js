// gcal-attendee-remove.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { attendeeRemove } from '../attendee/attendeeRemove.js';

await runBin(async () => {
  // Every positional argument is an e-mail address
  const { _: emails, named } = parseBinArgs({
    setAccount,
    minimist: { string: ['_', 'eventId', 'calendarId'] },
  });
  const output = await attendeeRemove({ emails, ...named });
  console.log(JSON.stringify(output, null, 2));
});
