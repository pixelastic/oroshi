import { firostError, select } from 'firost';

export let __;

const ACCOUNTS = [
  { name: '🟢 default', value: 'default' },
  { name: '🟡 test', value: 'test' },
];

/**
 * Ask the user which account to log in to
 * @returns {Promise<string>} The chosen account. "default" is the account without a suffix
 */
export async function askAccount() {
  // Only a human can sign in to Bluesky, so there is nothing to ask without a
  // terminal
  if (!process.stdin.isTTY) {
    throw firostError(
      'BLUESKY_LOGIN_NOT_INTERACTIVE',
      'bluesky-login needs a terminal to ask the account. Run it in your own shell, or pass --account',
    );
  }

  return await __.select('Which Bluesky account do you log in to?', ACCOUNTS);
}

__ = {
  select,
};
