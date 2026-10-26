import { __, waitForCode } from '../waitForCode.js';

describe('waitForCode', () => {
  const port = 48913;
  const authorizeUrl = 'https://accounts.google.com/o/oauth2/v2/auth?a=b';

  /**
   * Simulate the redirect of Google to the local callback server
   * @param {string} search - Query string of the redirect
   */
  function mockBrowserRedirect(search) {
    vi.spyOn(__, 'openBrowser').mockImplementation(async () => {
      const response = await fetch(
        `http://localhost:${port}/oauth2callback${search}`,
      );
      await response.text();
    });
  }

  it('opens the browser on the authorize url', async () => {
    mockBrowserRedirect('?code=auth-code');

    await waitForCode({ authorizeUrl, port });

    expect(__.openBrowser).toHaveBeenCalledWith(authorizeUrl);
  });

  it('returns the code of the callback', async () => {
    mockBrowserRedirect('?code=auth-code');

    const actual = await waitForCode({ authorizeUrl, port });

    expect(actual).toEqual('auth-code');
  });

  it('throws when the callback has no code', async () => {
    mockBrowserRedirect('?error=access_denied');

    let actual = null;
    try {
      await waitForCode({ authorizeUrl, port });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GOOGLE_LOGIN_FAILED');
    expect(actual).toHaveProperty('message', 'access_denied');
  });
});
