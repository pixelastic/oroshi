import { consoleWarn, readJson, run } from 'firost';
import { google } from 'googleapis';

export let __;

const tokenPath = `${process.env.OROSHI_TMP_FOLDER}/google/tokens.json`;

/**
 * Returns an authenticated Google OAuth2 client
 * @returns {object} Authenticated OAuth2Client
 */
export async function googleAuth() {
  let tokens;
  try {
    tokens = await __.readTokens();
  } catch {
    consoleWarn('No Google tokens found. Running google-login...');
    await __.runGoogleLogin();
    tokens = await __.readTokens();
  }

  const client = __.createOAuth2Client();
  client.setCredentials({ refresh_token: tokens.refresh_token });

  // Verify the token works by forcing a refresh
  try {
    await client.getAccessToken();
  } catch (error) {
    if (error.message?.includes('invalid_grant')) {
      consoleWarn('Google token expired. Running google-login...');
      await __.runGoogleLogin();
      tokens = await __.readTokens();
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
   * @returns {object} Token object with refresh_token
   */
  readTokens() {
    return readJson(tokenPath);
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
   * @returns {Promise<void>}
   */
  async runGoogleLogin() {
    await run('google-login', { stdin: 'inherit', stdout: 'inherit' });
  },
};
