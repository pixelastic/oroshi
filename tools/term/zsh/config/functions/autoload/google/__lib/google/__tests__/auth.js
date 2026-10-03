import { __, googleAuth } from '../auth.js';

describe('googleAuth', () => {
  let mockClient;

  beforeEach(() => {
    mockClient = {
      setCredentials: vi.fn(),
      getAccessToken: vi.fn(),
    };
    vi.spyOn(__, 'createOAuth2Client').mockReturnValue(mockClient);
    vi.spyOn(__, 'readTokens').mockReturnValue({
      access_token: 'stale-access-token',
      refresh_token: 'test-refresh-token',
      expiry_date: 1234567890,
    });
    vi.spyOn(__, 'runGoogleLogin').mockReturnValue();
    vi.spyOn(__, 'consoleWarn').mockReturnValue();
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

  it('runs google-login when token file is missing', async () => {
    let callCount = 0;
    vi.spyOn(__, 'readTokens').mockImplementation(() => {
      callCount++;
      if (callCount === 1) throw new Error('ENOENT');
      return { refresh_token: 'new-token' };
    });
    await googleAuth();
    expect(__.runGoogleLogin).toHaveBeenCalled();
    expect(__.consoleWarn).toHaveBeenCalledWith(
      expect.stringContaining('google-login'),
    );
  });

  it('re-authenticates on invalid_grant error', async () => {
    mockClient.getAccessToken.mockImplementationOnce(() => {
      throw new Error('invalid_grant');
    });
    await googleAuth();
    expect(__.runGoogleLogin).toHaveBeenCalled();
    expect(__.consoleWarn).toHaveBeenCalledWith(
      expect.stringContaining('expired'),
    );
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

    it.each([
      {
        title: 'logs in pro without flag',
        account: 'pro',
        expected: ['google-login'],
      },
      {
        title: 'logs in perso with --perso',
        account: 'perso',
        expected: ['google-login', '--perso'],
      },
      {
        title: 'logs in pro by default',
        account: undefined,
        expected: ['google-login'],
      },
    ])('$title', ({ account, expected }) => {
      const actual = __.loginCommand(account);
      expect(actual).toEqual(expected);
    });
  });
});
