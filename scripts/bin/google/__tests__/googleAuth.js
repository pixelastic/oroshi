import { consoleError } from 'firost';
import { __, googleAuth } from '../googleAuth.js';

vi.mock('firost', () => ({ consoleError: vi.fn() }));

describe('googleAuth', () => {
  let mockExit;
  let mockClient;

  beforeEach(() => {
    mockExit = vi.spyOn(process, 'exit').mockImplementation(() => {
      throw new Error('process.exit');
    });
    mockClient = { setCredentials: vi.fn() };
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

  it('exits with code 1 when token file is missing', async () => {
    vi.spyOn(__, 'readTokens').mockImplementation(() => {
      throw new Error('ENOENT');
    });
    let actual = null;
    try {
      await googleAuth();
    } catch (error) {
      actual = error;
    }
    expect(actual).not.toBeNull();
    expect(mockExit).toHaveBeenCalledWith(1);
  });

  it('prints error mentioning google-login when token file is missing', async () => {
    vi.spyOn(__, 'readTokens').mockImplementation(() => {
      throw new Error('ENOENT');
    });
    let actual = null;
    try {
      await googleAuth();
    } catch (error) {
      actual = error;
    }
    expect(actual).not.toBeNull();
    expect(consoleError).toHaveBeenCalledWith(
      expect.stringContaining('google-login'),
    );
  });
});
