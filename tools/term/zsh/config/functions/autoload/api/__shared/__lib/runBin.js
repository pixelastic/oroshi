import { _ } from 'golgoth';

/**
 * Run the main function of a bin
 * A firostError (a code and a message) is printed as CODE: message on stderr,
 * and the process exits with code 1. Any other error is rethrown, so Node
 * prints its stack trace
 * @param {Function} main - Main function of the bin
 * @returns {Promise<void>} Resolves when the main function resolves
 */
export async function runBin(main) {
  try {
    await main();
  } catch (error) {
    if (!_.isString(error?.code) || !_.isString(error?.message)) {
      throw error;
    }
    console.error(`${error.code}: ${error.message}`);
    process.exit(1);
  }
}
