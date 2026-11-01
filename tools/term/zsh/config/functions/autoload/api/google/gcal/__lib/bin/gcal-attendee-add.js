// gcal-attendee-add.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { attendeeAdd } from '../attendee/attendeeAdd.js';

await runBin(async () => {
  // Every positional argument is an e-mail address
  const { _: emails, named } = parseBinArgs({
    setAccount,
    minimist: { string: ['_', 'eventId', 'calendarId'] },
  });
  const output = await attendeeAdd({ emails, ...named });
  console.log(JSON.stringify(output, null, 2));
});
