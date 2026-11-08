import { readJson, remove, tmpDirectory } from 'firost';
import { __, login } from '../login.js';

describe('login', () => {
  let testDirectory;
  let client;
  beforeEach(() => {
    testDirectory = tmpDirectory('bluesky/login');
    vi.stubEnv('OROSHI_FOLDER_STATE', testDirectory);
    client = {
      authorize: vi.fn().mockReturnValue(new URL('https://bsky.social/auth')),
      callback: vi.fn(),
    };
    // The library saves the session in the store it is given, as the real one
    vi.spyOn(__, 'createOAuthClient').mockImplementation(({ sessionStore }) => {
      client.callback.mockImplementation(async () => {
        await sessionStore.set('did:plc:abc', { tokenSet: 'granted' });
        return { session: { sub: 'did:plc:abc' } };
      });
      return client;
    });
    vi.spyOn(__, 'waitForRedirect').mockReturnValue(
      new URLSearchParams({ code: 'auth-code', state: 'xyz' }),
    );
  });
  afterEach(async () => {
    vi.unstubAllEnvs();
    await remove(testDirectory);
  });

  it.each([
    { title: 'no account', input: undefined, expected: 'tokens.json' },
    { title: 'the default account', input: 'default', expected: 'tokens.json' },
    { title: 'the test account', input: 'test', expected: 'tokens-test.json' },
  ])('writes the tokens file for $title', async ({ input, expected }) => {
    const actual = await login({ account: input });

    expect(actual).toEqual(`${testDirectory}/bluesky/${expected}`);
    expect(await readJson(actual)).toHaveProperty(
      'sessions.did:plc:abc.tokenSet',
      'granted',
    );
  });

  it('sends the user to the authorization page, then back to the library', async () => {
    await login();

    const { authorizeUrl } = __.waitForRedirect.mock.calls[0][0];
    expect(authorizeUrl).toEqual('https://bsky.social/auth');
    const [params] = client.callback.mock.calls[0];
    expect(params.get('code')).toEqual('auth-code');
  });
});
