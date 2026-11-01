// gcal-event-search.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { eventSearch } from '../event/eventSearch.js';

await runBin(async () => {
  // The text to search is the positional argument. The dates and the id stay
  // strings, so that the module reports a bad value
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: {
      boolean: ['today', 'week'],
      string: ['date-min', 'date-max', 'calendarId'],
    },
  });
  const output = await eventSearch({ query: positional, ...named });
  console.log(output);
});
