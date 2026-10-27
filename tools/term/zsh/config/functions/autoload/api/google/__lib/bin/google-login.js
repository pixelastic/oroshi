// google-login.js
import { parseBinArgs } from '@oroshi/api-shared/parseBinArgs.js';
import { runBin } from '@oroshi/api-shared/runBin.js';
import { askAccount } from '../askAccount.js';
import { login } from '../login.js';

await runBin(async () => {
  // login writes the tokens of an account, so it keeps the account for itself
  let account;
  parseBinArgs({
    setAccount(value) {
      account = value;
    },
  });

  // Without --account, the user must choose, or the tokens land in the wrong
  // file
  account ||= await askAccount();

  const output = await login({ account });
  console.log(output);
});
