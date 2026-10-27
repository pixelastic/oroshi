import { _ } from 'golgoth';
import { env, firostError } from 'firost';
import { getAccount } from '@oroshi/google/getAccount.js';

/**
 * Read the aliases of the current account from the environment
 * @returns {string[]} The addresses of the aliases. Throws GMAIL_ALIASES_MISSING if the variable is empty
 */
export function getAliases() {
  const account = getAccount();
  const name = account
    ? `OROSHI_GMAIL_ALIASES_${_.toUpper(account)}`
    : 'OROSHI_GMAIL_ALIASES';
  const aliases = _.chain(env(name) || '')
    .split(',')
    .map(_.trim)
    .compact()
    .value();

  if (_.isEmpty(aliases)) {
    throw firostError('GMAIL_ALIASES_MISSING', `Set ${name}`);
  }

  return aliases;
}
