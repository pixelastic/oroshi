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
