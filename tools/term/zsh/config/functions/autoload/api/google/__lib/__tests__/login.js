import { readJson, remove, tmpDirectory } from 'firost';
import { __, login } from '../login.js';

describe('login', () => {
  const grant = { access_token: 'ya29', refresh_token: 'r/1' };

  let testDirectory;
  beforeEach(() => {
    testDirectory = tmpDirectory('google/login');
    vi.stubEnv('OROSHI_FOLDER_STATE', testDirectory);
    vi.spyOn(__, 'getClientCredentials').mockReturnValue({
      clientId: 'client-id',
      clientSecret: 'client-secret',
    });
    vi.spyOn(__, 'waitForCode').mockReturnValue('auth-code');
    vi.spyOn(__, 'postToken').mockReturnValue(grant);
  });
  afterEach(async () => {
    vi.unstubAllEnvs();
    await remove(testDirectory);
  });

  it.each([
    { title: 'no account', input: undefined, expected: 'tokens.json' },
    { title: 'an account', input: 'perso', expected: 'tokens-perso.json' },
  ])('writes the tokens file for $title', async ({ input, expected }) => {
    const actual = await login({ account: input });

    expect(actual).toEqual(`${testDirectory}/google/${expected}`);
    expect(await readJson(actual)).toEqual(grant);
  });

  it('opens the consent page of the client, for the Google scopes', async () => {
    await login();

    const { authorizeUrl, port } = __.waitForCode.mock.calls[0][0];
    const url = new URL(authorizeUrl);
    expect(url.origin + url.pathname).toEqual(
      'https://accounts.google.com/o/oauth2/v2/auth',
    );
    expect(Object.fromEntries(url.searchParams)).toEqual({
      client_id: 'client-id',
      redirect_uri: 'http://localhost:48912/oauth2callback',
      response_type: 'code',
      access_type: 'offline',
      prompt: 'consent select_account',
      scope: [
        'https://www.googleapis.com/auth/documents',
        'https://www.googleapis.com/auth/drive',
        'https://www.googleapis.com/auth/gmail.readonly',
        'https://www.googleapis.com/auth/gmail.compose',
      ].join(' '),
    });
    expect(port).toEqual(48912);
  });

  it('exchanges the code of the grant for tokens', async () => {
    await login();

    expect(__.postToken).toHaveBeenCalledWith({
      grant_type: 'authorization_code',
      code: 'auth-code',
      redirect_uri: 'http://localhost:48912/oauth2callback',
    });
  });
});
