# `setAccount`

`setAccount` chooses the account that [`getConfig`](getConfig.md) reads, for the
whole command.

## Role

- Every service has one, in `<service>/__lib/setAccount.js`.
- No other module receives the account, and none forwards it.
- It changes the private `account` that `getConfig` holds in its `__`.

## Inputs/Outputs

- Input: the name of the account. An empty value selects the default account.
- Output: none.

## Template

`<service>/__lib/setAccount.js`:

```javascript
import { __ as configInternals } from './getConfig.js';

/**
 * Choose the account that getConfig reads
 * @param {string} [account] - Name of the account. Default account if empty
 */
export function setAccount(account) {
  // Store it in the private state of getConfig. An empty value goes back to
  // null, the default account
  configInternals.account = account || null;
}
```

The test covers the function only. It calls `setAccount` and checks that
`getConfig` returns the credentials of that account, then that an empty value
brings back the default account.
