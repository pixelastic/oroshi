import { __ as configInternals } from './getConfig.js';

/**
 * Read the account that setAccount chose
 * @returns {string|null} Name of the account. Null is the default account
 */
export function getAccount() {
  return configInternals.account;
}
