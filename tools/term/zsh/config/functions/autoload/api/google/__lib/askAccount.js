import { firostError, select } from 'firost';

export let __;

const ACCOUNTS = [
  { name: '🔵 default', value: 'default' },
  { name: '🟢 perso', value: 'perso' },
];

/**
 * Ask the user which account to log in to
 * @returns {Promise<string>} The chosen account. "default" is the account without a suffix
 */
export async function askAccount() {
  // Only a human can sign in to Google, so there is nothing to ask without a
  // terminal
  if (!process.stdin.isTTY) {
    throw firostError(
      'GOOGLE_LOGIN_NOT_INTERACTIVE',
      'google-login needs a terminal to ask the account. Run it in your own shell, or pass --account',
    );
  }

  return await __.select('Which Google account do you log in to?', ACCOUNTS);
}

__ = {
  select,
};
