// gdoc-document-create.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { setAccount } from '@oroshi/google/setAccount.js';
import { documentCreate } from '../document/documentCreate.js';
import { openUrl } from '../openUrl.js';

await runBin(async () => {
  // The path of the file is the positional argument. A flag that must stay a
  // string or a boolean is declared in the minimist options
  const { positional, named } = parseBinArgs({
    setAccount,
    minimist: { boolean: ['open'], string: ['title', 'directory'] },
  });
  const { open, ...options } = named;
  const output = await documentCreate({ filepath: positional, ...options });
  console.log(JSON.stringify(output, null, 2));

  // Opening is opt-in, and happens after the output is printed
  if (open) {
    await openUrl(output.url);
  }
});
