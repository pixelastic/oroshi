import { exists, firostError, readJson } from 'firost';
import { getClientCredentials } from './getClientCredentials.js';
import { tokensPath } from './tokensPath.js';

export let __;

/**
 * Read the OAuth tokens and the OAuth client of Google
 * @returns {Promise<object>} The tokens of the selected account, with the client id and secret
 */
export async function getConfig() {
  const { account } = __;

  // The client comes from the environment, the tokens from the file written by
  // google-login
  const { clientId, clientSecret } = getClientCredentials();
  const path = tokensPath(account);

  // Fail early when the user never logged in
  if (!(await exists(path))) {
    const command = account
      ? `run google-login --account ${account}`
      : 'run google-login';
    throw firostError('GOOGLE_LOGIN_REQUIRED', command);
  }

  const tokens = await readJson(path);

  return { tokens, clientId, clientSecret };
}

// The account that setAccount changes. Null is the default account
__ = {
  account: null,
};
