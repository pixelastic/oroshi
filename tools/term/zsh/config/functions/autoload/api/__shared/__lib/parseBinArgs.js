import { _ } from 'golgoth';
import minimist from 'minimist';

export let __;

/**
 * Parse the arguments of a bin into its positional argument and named flags
 * The only side effect is calling setAccount with the --account flag
 * @param {object} options - Options of the parser
 * @param {Function} options.setAccount - Sets the account of the service
 * @param {object} [options.minimist] - Options passed to minimist
 * @returns {{positional: string|undefined, named: object, _: Array}} The first positional argument, the named flags in camelCase without account, and the raw positional arguments
 */
export function parseBinArgs(options) {
  const {
    _: raw,
    account,
    ...flags
  } = minimist(__.getArgs(), options.minimist);

  options.setAccount(account);

  const positional = _.isUndefined(raw[0]) ? undefined : String(raw[0]);
  const named = _.mapKeys(flags, (_value, key) => _.camelCase(key));

  return { positional, named, _: raw };
}

__ = {
  /**
   * Get the arguments of the process, without the node and script paths
   * @returns {string[]} The arguments
   */
  getArgs() {
    return process.argv.slice(2);
  },
};
