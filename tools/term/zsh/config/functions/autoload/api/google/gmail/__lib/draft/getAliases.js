import { _ } from 'golgoth';
import { env, firostError } from 'firost';

/**
 * Read the aliases of the user from the environment
 * @param {string} [account] - Name of the account. Default account if empty
 * @returns {string[]} The addresses of the aliases. Throws GMAIL_ALIASES_MISSING if the variable is empty
 */
export function getAliases(account) {
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
