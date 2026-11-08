import { createOAuthClient } from './createOAuthClient.js';
import { createStores } from './createStores.js';
import { LOOPBACK_PORT } from './loopbackPort.js';
import { tokensPath } from './tokensPath.js';
import { waitForRedirect } from './waitForRedirect.js';

export let __;

// The user picks the Bluesky account in the browser
const ENTRYWAY = 'https://bsky.social';

/**
 * Log in to Bluesky, and save the OAuth session
 * @param {object} [options] - Login options
 * @param {string} [options.account] - Account to log in to. Default if empty
 * @returns {Promise<string>} The path of the tokens file
 */
export async function login(options = {}) {
  const { account } = options;

  // The stores of the client write the session in the tokens file
  const path = tokensPath(account);
  const client = __.createOAuthClient(createStores(path));

  // Send the user to the authorization page, and wait for the redirect
  const authorizeUrl = await client.authorize(ENTRYWAY);
  const params = await __.waitForRedirect({
    authorizeUrl: authorizeUrl.href,
    port: LOOPBACK_PORT,
  });

  // The library exchanges the code, and saves the session
  await client.callback(params);

  return path;
}

__ = {
  createOAuthClient,
  waitForRedirect,
};
