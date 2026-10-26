import { writeJson } from 'firost';
import { getClientCredentials } from './getClientCredentials.js';
import { postToken } from './postToken.js';
import { tokensPath } from './tokensPath.js';
import { waitForCode } from './waitForCode.js';

export let __;

const PORT = 48912;
const REDIRECT_URI = `http://localhost:${PORT}/oauth2callback`;
const AUTHORIZE_URL = 'https://accounts.google.com/o/oauth2/v2/auth';
const SCOPES = [
  'https://www.googleapis.com/auth/documents',
  'https://www.googleapis.com/auth/drive',
  'https://www.googleapis.com/auth/gmail.readonly',
];

/**
 * Log in to Google, and save the OAuth tokens
 * @param {object} [options] - Login options
 * @param {string} [options.account] - Account to log in to. Default if empty
 * @returns {Promise<string>} The path of the tokens file
 */
export async function login(options = {}) {
  const { account } = options;

  // Send the user to the consent page, and wait for the code Google sends back
  const { clientId } = __.getClientCredentials();
  const authorizeUrl = `${AUTHORIZE_URL}?${new URLSearchParams({
    client_id: clientId,
    redirect_uri: REDIRECT_URI,
    response_type: 'code',
    access_type: 'offline',
    prompt: 'consent select_account',
    scope: SCOPES.join(' '),
  })}`;
  const code = await __.waitForCode({ authorizeUrl, port: PORT });

  // Exchange the code for the tokens
  const tokens = await __.postToken({
    grant_type: 'authorization_code',
    code,
    redirect_uri: REDIRECT_URI,
  });

  // Save the tokens. The default account uses tokens.json, another account
  // uses tokens-<account>.json
  const path = tokensPath(account);
  await writeJson(tokens, path);

  return path;
}

__ = {
  getClientCredentials,
  postToken,
  waitForCode,
};
