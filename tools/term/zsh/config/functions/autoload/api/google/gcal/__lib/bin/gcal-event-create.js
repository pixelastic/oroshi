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
    options: {
      title: { type: 'string' },
      'date-start': { type: 'string' },
      'date-end': { type: 'string' },
      location: { type: 'string' },
      description: { type: 'string' },
      'description-file': { type: 'string' },
      attendees: { type: 'string' },
      recurrence: { type: 'string' },
      calendarId: { type: 'string' },
      private: { type: 'boolean' },
      public: { type: 'boolean' },
    },
  });
  // private is a reserved word, so the flags are renamed to the options of the
  // module
  const { private: isPrivate, public: isPublic, ...fields } = named;
  const output = await eventCreate({ ...fields, isPrivate, isPublic });
  console.log(JSON.stringify(output, null, 2));
});
