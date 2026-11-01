import { parseArgs } from 'node:util';
import { _ } from 'golgoth';
import minimist from 'minimist';

export let __;

/**
 * Parse the arguments of a bin into its positional argument and named flags
 * The only side effect is calling setAccount with the --account flag
 * @param {object} options - Options of the parser
 * @param {Function} options.setAccount - Sets the account of the service
 * @param {object} [options.options] - Options in the native parseArgs format. When set, the parser is strict and throws the native error on a bad flag
 * @param {object} [options.minimist] - Options passed to minimist, used when options.options is not set
 * @returns {{positional: string|undefined, named: object, _: Array}} The first positional argument, the named flags in camelCase without account, and the raw positional arguments
 */
export function parseBinArgs(options) {
  const { raw, account, flags } = options.options
    ? __.parseNative(options.options)
    : __.parseMinimist(options.minimist);

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
  /**
   * Parse the arguments with minimist
   * @param {object} [minimistOptions] - Options passed to minimist
   * @returns {{raw: Array, account: string|undefined, flags: object}} The raw positionals, the account and the other flags
   */
  parseMinimist(minimistOptions) {
    const {
      _: raw,
      account,
      ...flags
    } = minimist(__.getArgs(), minimistOptions);
    return { raw, account, flags };
  },
  /**
   * Parse the arguments with the native parseArgs, in strict mode
   * @param {object} nativeOptions - Options in the native parseArgs format
   * @returns {{raw: string[], account: string|undefined, flags: object}} The raw positionals, the account and the other flags
   */
  parseNative(nativeOptions) {
    const { positionals, values } = parseArgs({
      args: __.getArgs(),
      options: { ...nativeOptions, account: { type: 'string' } },
      strict: true,
      allowPositionals: true,
    });
    const { account, ...flags } = values;
    return { raw: positionals, account, flags };
  },
};
