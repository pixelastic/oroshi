/**
 * Get the command that logs the user in to Bluesky
 * @param {string} [account] - Name of the account. Default account if empty
 * @returns {string} The message that tells the user what to run
 */
export function loginCommand(account) {
  return account
    ? `run bluesky-login --account ${account}`
    : 'run bluesky-login';
}
