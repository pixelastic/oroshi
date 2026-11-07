import { exists, firostError, readJson } from 'firost';
import { loginCommand } from './loginCommand.js';
import { tokensPath } from './tokensPath.js';

export let __;

/**
 * Read the OAuth tokens of Bluesky
 * @returns {Promise<object>} The tokens of the selected account
 */
export async function getConfig() {
  const { account } = __;
  const path = tokensPath(account);

  // Fail early when the user never logged in
  if (!(await exists(path))) {
    throw firostError('BLUESKY_LOGIN_REQUIRED', loginCommand(account));
  }

  const tokens = await readJson(path);

  return { tokens };
}

// The account that setAccount changes. Null is the default account
__ = {
  account: null,
};
