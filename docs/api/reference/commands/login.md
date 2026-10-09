# `login`

`login` gets the OAuth tokens of a service and saves them, so that the other
commands can call the API.

## Example

```text
$ confluence-login
$ confluence-login --account perso
```

## Role

- `login` is optional. Only an OAuth API needs it. A key API has no login, and
  must not build one.
- It is the only command that is not named `<service>-<entity>-<verb>`. It is
  named `<service>-login`, and has no entity.
- It opens a browser, so that the user grants access. It gets the tokens, and
  saves them.
- The tokens go to the state folder of the service:
  `$OROSHI_FOLDER_STATE/<service>/tokens.json`.
- The default account uses `tokens.json`. Another account uses
  `tokens-<account>.json` in the same folder.
- When the grant is missing or expired, the other commands fail with the typed
  error `<SERVICE>_LOGIN_REQUIRED`. Its message points to this command:
  `run <service>-login`.
- No command logs in by itself. Only `<service>-login` opens a browser, and the
  user runs it by hand.

## Arguments

`login` takes no positional argument. It takes the `--account` flag, defined in
[arguments.md](../../arguments.md#--account).

## Template

`login` has the same three layers as the other commands: a wrapper, a bin and a
module. It lives at the root of the service, not in an entity folder.

### ZSH Wrapper

`<service>/<service>-login`:

```zsh
# Log in to <service>, and save the OAuth tokens
# Usage:
# $ <service>-login
# $ <service>-login --account perso
setopt local_options err_return

local libDir="${functions_source[$0]:A:h}/__lib"
node "${libDir}/bin/<service>-login.js" "$@"
```

### JS Bin

The bin parses the args, calls the module and prints the path of the file it
wrote.

`<service>/__lib/bin/<service>-login.js`:

```javascript
// <service>-login.js
import minimist from 'minimist';
import { login } from '../login.js';

const { account } = minimist(process.argv.slice(2));
const output = await login({ account });
console.log(output);
```

### Module

The module takes the account, and returns the path of the tokens file.

`<service>/__lib/login.js`:

```javascript
import { absolute, env, writeJson } from 'firost';

export let __;

/**
 * Log in to the service, and save the OAuth tokens
 * @param {object} [options] - Login options
 * @param {string} [options.account] - Account to log in to. Default if empty
 * @returns {Promise<string>} The path of the tokens file
 */
export async function login(options = {}) {
  const { account } = options;

  // Open the browser on the authorization page of the service
  // Wait for the grant (a local callback server, or a code pasted back)
  // Exchange the grant for the tokens
  const tokens = {};

  // Save the tokens. The default account uses tokens.json, another account
  // uses tokens-<account>.json
  const filename = account ? `tokens-${account}.json` : 'tokens.json';
  const tokensPath = absolute(
    env('OROSHI_FOLDER_STATE'),
    '<service>',
    filename,
  );
  await writeJson(tokens, tokensPath);

  // Return the path of the tokens file
  return tokensPath;
}

__ = {
  // Everything that opens a browser, waits for the grant or calls the
  // service to exchange it
};
```

### Test

The vitest test covers the module only. It mocks everything that opens a
browser (and everything that waits for the grant or exchanges it) through `__`.
It points `OROSHI_FOLDER_STATE` to a temporary folder, and mostly checks three
behaviors:
- Given no account, the module writes the tokens to `<service>/tokens.json`.
- Given an account, the module writes them to `<service>/tokens-<account>.json`.
- The JSON written holds the token given by the mocked grant.

The zsh wrapper and the bin are so thin that they need no test.
