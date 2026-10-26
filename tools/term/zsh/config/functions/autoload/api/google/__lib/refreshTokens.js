import { writeJson } from 'firost';
import { __ as configInternals } from './getConfig.js';
import { postToken } from './postToken.js';
import { tokensPath } from './tokensPath.js';

export let __;

/**
 * Get a fresh access token from the refresh token, and rewrite the tokens file
 * @param {object} tokens - The current tokens, holding the refresh_token
 * @returns {Promise<object>} The new tokens, with the expiry date as expires_at
 */
export async function refreshTokens(tokens) {
  const refreshed = await __.postToken({
    grant_type: 'refresh_token',
    refresh_token: tokens.refresh_token,
  });

  // Google does not send the refresh token back, so the old one is kept.
  // expires_at (in ms) lets callApi know when to refresh again
  const newTokens = {
    ...tokens,
    ...refreshed,
    expires_at: Date.now() + refreshed.expires_in * 1000,
  };
  await writeJson(newTokens, tokensPath(configInternals.account));

  return newTokens;
}

__ = {
  postToken,
};
