import { firostError } from 'firost';
import { __, resolveHandle } from '../resolveHandle.js';

describe('resolveHandle', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ did: 'did:plc:abc' });
  });

  it('asks the PDS for the DID of the handle', async () => {
    const actual = await resolveHandle('a.bsky.social');

    expect(__.callApi).toHaveBeenCalledWith(
      'com.atproto.identity.resolveHandle',
      { query: { handle: 'a.bsky.social' } },
    );
    expect(actual).toEqual('did:plc:abc');
  });

  it('returns null when the PDS answers 400', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError(
        'BLUESKY_REQUEST_FAILED',
        '400 {"error":"InvalidRequest","message":"Unable to resolve handle"}',
      );
    });

    const actual = await resolveHandle('unknown.bsky.social');

    expect(actual).toBeNull();
  });

  it('lets the other API errors through', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('BLUESKY_LOGIN_REQUIRED', 'Log in');
    });

    let actual = null;
    try {
      await resolveHandle('a.bsky.social');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_LOGIN_REQUIRED');
  });
});
