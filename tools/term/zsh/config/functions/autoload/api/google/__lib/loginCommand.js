/**
 * Get the command that logs the user in to Google
 * @param {string} [account] - Name of the account. Default account if empty
 * @returns {string} The message that tells the user what to run
 */
export function loginCommand(account) {
  return account ? `run google-login --account ${account}` : 'run google-login';
}
