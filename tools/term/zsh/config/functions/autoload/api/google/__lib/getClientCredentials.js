import { env, firostError } from 'firost';

/**
 * Read the OAuth client of the Google app from the environment
 * @returns {{clientId: string, clientSecret: string}} The client id and secret
 */
export function getClientCredentials() {
  const clientId = env('OROSHI_GOOGLE_CLIENT_ID');
  const clientSecret = env('OROSHI_GOOGLE_CLIENT_SECRET');

  // Fail early when a variable is empty
  if (!clientId) {
    throw firostError(
      'GOOGLE_CREDENTIALS_MISSING',
      'Set OROSHI_GOOGLE_CLIENT_ID',
    );
  }
  if (!clientSecret) {
    throw firostError(
      'GOOGLE_CREDENTIALS_MISSING',
      'Set OROSHI_GOOGLE_CLIENT_SECRET',
    );
  }

  return { clientId, clientSecret };
}
