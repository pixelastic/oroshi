import { NodeOAuthClient } from '@atproto/oauth-client-node';
import { LOOPBACK_PORT } from './loopbackPort.js';

// Scopes are not validated against the real PDS yet: granular scopes may need
// a broader fallback
const SCOPE = 'atproto repo:app.bsky.feed.post blob:image/*';

/**
 * Create the OAuth client of the loopback application
 * @param {object} options - Client options
 * @param {object} options.stateStore - Store of the authorization requests
 * @param {object} options.sessionStore - Store of the sessions
 * @returns {NodeOAuthClient} The client, that signs requests (DPoP) and refreshes tokens
 */
export function createOAuthClient(options) {
  const { stateStore, sessionStore } = options;

  // A loopback client has no public metadata file: its metadata is encoded in
  // its client_id
  const redirectUri = `http://127.0.0.1:${LOOPBACK_PORT}/callback`;
  const clientId = `http://localhost?${new URLSearchParams({
    redirect_uri: redirectUri,
    scope: SCOPE,
  })}`;

  return new NodeOAuthClient({
    clientMetadata: {
      client_id: clientId,
      client_name: 'oroshi bluesky',
      redirect_uris: [redirectUri],
      scope: SCOPE,
      grant_types: ['authorization_code', 'refresh_token'],
      response_types: ['code'],
      token_endpoint_auth_method: 'none',
      application_type: 'native',
      dpop_bound_access_tokens: true,
    },
    stateStore,
    sessionStore,
    // One process at a time refreshes the tokens, so no lock is needed
    requestLock: (_name, fn) => fn(),
  });
}
