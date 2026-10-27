import { absolute, env } from 'firost';

/**
 * Get the path of the tokens file of an account
 * @param {string} [account] - Name of the account. Default account if empty or "default"
 * @returns {string} The path of tokens.json, or of tokens-<account>.json
 */
export function tokensPath(account) {
  const isDefault = !account || account === 'default';
  const filename = isDefault ? 'tokens.json' : `tokens-${account}.json`;
  return absolute(env('OROSHI_FOLDER_STATE'), 'google', filename);
}
