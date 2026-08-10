import { consoleWarn } from 'firost';
import { __, googleAuth } from '../__lib/googleAuth.js';

vi.mock('firost', () => ({
  consoleWarn: vi.fn(),
  run: vi.fn(),
}));

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
    vi.spyOn(__, 'runGoogleLogin').mockResolvedValue();
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
    expect(consoleWarn).toHaveBeenCalledWith(
      expect.stringContaining('google-login'),
    );
  });

  it('re-authenticates on invalid_grant error', async () => {
    mockClient.getAccessToken.mockRejectedValueOnce(new Error('invalid_grant'));
    await googleAuth();
    expect(__.runGoogleLogin).toHaveBeenCalled();
    expect(consoleWarn).toHaveBeenCalledWith(
      expect.stringContaining('expired'),
    );
  });

  it('throws on unexpected getAccessToken errors', async () => {
    mockClient.getAccessToken.mockRejectedValueOnce(
      new Error('network failure'),
    );
    await expect(googleAuth()).rejects.toThrow('network failure');
  });
});
