import { consoleError, readJson } from 'firost';
import { google } from 'googleapis';

export let __;

const tokenPath = `${process.env.OROSHI_ROOT}/private/config/google/tokens.json`;

/**
 * Returns an authenticated Google OAuth2 client
 * @returns {object} Authenticated OAuth2Client
 */
export async function googleAuth() {
  let tokens;
  try {
    tokens = await __.readTokens();
  } catch {
    consoleError('No Google tokens found. Run google-login first.');
    process.exit(1);
  }

  const client = __.createOAuth2Client();
  client.setCredentials({ refresh_token: tokens.refresh_token });
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
};
