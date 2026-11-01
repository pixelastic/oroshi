import { parseArgs } from 'node:util';
import { _ } from 'golgoth';

export let __;

/**
 * Parse the arguments of a bin into its positional argument and named flags
 * The only side effect is calling setAccount with the --account flag
 * @param {object} options - Options of the parser
 * @param {Function} options.setAccount - Sets the account of the service
 * @param {object} options.options - Options in the native parseArgs format. The parser is strict and throws the native error on a bad flag
 * @returns {{positional: string|undefined, named: object, _: string[]}} The first positional argument, the named flags in camelCase without account, and the raw positional arguments
 */
export function parseBinArgs(options) {
  const { raw, account, flags } = __.parseNative(options.options);

  options.setAccount(account);

  const positional = raw[0];
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
