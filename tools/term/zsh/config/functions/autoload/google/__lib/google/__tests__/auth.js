import childProcess from 'node:child_process';
import { __, googleAuth } from '../auth.js';

describe('googleAuth', () => {
  let mockClient;

  beforeEach(() => {
    mockClient = {
      setCredentials: vi.fn(),
      getAccessToken: vi.fn(),
    };
    vi.spyOn(childProcess, 'spawn').mockReturnValue();
    vi.spyOn(__, 'createOAuth2Client').mockReturnValue(mockClient);
    vi.spyOn(__, 'readTokens').mockReturnValue({
      access_token: 'stale-access-token',
      refresh_token: 'test-refresh-token',
      expiry_date: 1234567890,
    });
  });

  it('returns an authenticated OAuth2 client', async () => {
    const actual = await googleAuth();
    expect(actual).toBe(mockClient);
  });

  it('sets refresh token as credentials on the client', async () => {
    await googleAuth();
    expect(mockClient.setCredentials).toHaveBeenCalledWith({
      refresh_token: 'test-refresh-token',
    });
  });

  describe('login required', () => {
    const missing = () => {
      vi.spyOn(__, 'readTokens').mockImplementation(() => {
        throw new Error('ENOENT');
      });
    };
    const expired = () => {
      mockClient.getAccessToken.mockImplementation(() => {
        throw new Error('invalid_grant');
      });
    };

    it.each([
      {
        title: 'no token file exists',
        arrange: missing,
        account: 'pro',
        expected: 'Google account "pro" is not logged in. Run google-login',
      },
      {
        title: 'the token expired',
        arrange: expired,
        account: 'pro',
        expected: 'Google token of account "pro" expired. Run google-login',
      },
      {
        title: 'no token file exists for perso',
        arrange: missing,
        account: 'perso',
        expected:
          'Google account "perso" is not logged in. Run google-login --perso',
      },
      {
        title: 'the token of perso expired',
        arrange: expired,
        account: 'perso',
        expected:
          'Google token of account "perso" expired. Run google-login --perso',
      },
    ])(
      'throws GOOGLE_LOGIN_REQUIRED when $title',
      async ({ arrange, account, expected }) => {
        arrange();
        let actual = null;
        try {
          await googleAuth(account);
        } catch (error) {
          actual = error;
        }
        expect(actual).toHaveProperty('code', 'GOOGLE_LOGIN_REQUIRED');
        expect(actual).toHaveProperty('message', expected);
      },
    );

    it('never spawns a process', async () => {
      missing();
      try {
        await googleAuth();
      } catch {
        // The error is expected
      }
      expect(childProcess.spawn).not.toHaveBeenCalled();
    });
  });

  it('throws on unexpected getAccessToken errors', async () => {
    mockClient.getAccessToken.mockImplementationOnce(() => {
      throw new Error('network failure');
    });
    await expect(googleAuth()).rejects.toThrow('network failure');
  });

  describe('account selection', () => {
    beforeEach(() => {
      vi.stubEnv('OROSHI_FOLDER_STATE', '/state');
    });
    afterEach(() => {
      vi.unstubAllEnvs();
    });

    it.each([
      {
        title: 'reads tokens.json for the pro account',
        args: ['pro'],
        expected: '/state/google/tokens.json',
      },
      {
        title: 'reads tokens-perso.json for the perso account',
        args: ['perso'],
        expected: '/state/google/tokens-perso.json',
      },
      {
        title: 'defaults to pro when no account is given',
        args: [],
        expected: '/state/google/tokens.json',
      },
    ])('$title', async ({ args, expected }) => {
      const actual = __.tokenPath(...args);
      expect(actual).toEqual(expected);
    });

    it('passes the account to readTokens', async () => {
      vi.spyOn(__, 'readTokens').mockReturnValue({ refresh_token: 'x' });
      await googleAuth('perso');
      expect(__.readTokens).toHaveBeenCalledWith('perso');
    });

    it('defaults to the pro account', async () => {
      vi.spyOn(__, 'readTokens').mockReturnValue({ refresh_token: 'x' });
      await googleAuth();
      expect(__.readTokens).toHaveBeenCalledWith('pro');
    });
  });
});
