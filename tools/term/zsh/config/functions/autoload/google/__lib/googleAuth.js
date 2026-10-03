import { consoleWarn, readJson, run } from 'firost';
import { google } from 'googleapis';

export let __;

/**
 * Returns an authenticated Google OAuth2 client
 * @param {string} account - Account to authenticate: "pro" (default) or "perso"
 * @returns {object} Authenticated OAuth2Client
 */
export async function googleAuth(account = 'pro') {
  let tokens;
  try {
    tokens = await __.readTokens(account);
  } catch {
    __.consoleWarn('No Google tokens found. Running google-login...');
    await __.runGoogleLogin(account);
    tokens = await __.readTokens(account);
  }

  const client = __.createOAuth2Client();
  client.setCredentials({ refresh_token: tokens.refresh_token });

  // Verify the token works by forcing a refresh
  try {
    await client.getAccessToken();
  } catch (error) {
    if (error.message?.includes('invalid_grant')) {
      __.consoleWarn('Google token expired. Running google-login...');
      await __.runGoogleLogin(account);
      tokens = await __.readTokens(account);
      client.setCredentials({ refresh_token: tokens.refresh_token });
    } else {
      throw error;
    }
  }

  return client;
}

__ = {
  /**
   * Read stored tokens from disk
   * @param {string} account - "pro" (tokens.json) or "perso" (tokens-perso.json)
   * @returns {object} Token object with refresh_token
   */
  readTokens(account = 'pro') {
    return readJson(__.tokenPath(account));
  },
  /**
   * Path of the token file of an account
   * @param {string} account - "pro" (tokens.json) or "perso" (tokens-perso.json)
   * @returns {string} Token file path
   */
  tokenPath(account = 'pro') {
    const suffix = account === 'pro' ? '' : `-${account}`;
    return `${process.env.OROSHI_FOLDER_STATE}/google/tokens${suffix}.json`;
  },
  /**
   * Command that logs in an account
   * @param {string} account - "pro" or "perso"
   * @returns {string[]} Command and arguments
   */
  loginCommand(account = 'pro') {
    return account === 'pro'
      ? ['google-login']
      : ['google-login', `--${account}`];
  },
  /**
   * Create a new OAuth2Client instance
   * @returns {object} OAuth2Client
   */
  createOAuth2Client() {
    return new google.auth.OAuth2(
      process.env.OROSHI_GOOGLE_CLIENT_ID,
      process.env.OROSHI_GOOGLE_CLIENT_SECRET,
    );
  },
  /**
   * Run google-login and wait for the user to complete auth
   * @param {string} account - "pro" or "perso"
   * @returns {Promise<void>}
   */
  async runGoogleLogin(account = 'pro') {
    await run(__.loginCommand(account), {
      stdin: 'inherit',
      stdout: 'inherit',
    });
  },
  /**
   * Print a warning
   * @param {string} message - Warning text
   */
  consoleWarn(message) {
    consoleWarn(message);
  },
};
