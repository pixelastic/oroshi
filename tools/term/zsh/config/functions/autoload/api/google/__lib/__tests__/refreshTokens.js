import { readJson, remove, tmpDirectory, writeJson } from 'firost';
import { __ as configInternals } from '../getConfig.js';
import { __, refreshTokens } from '../refreshTokens.js';

describe('refreshTokens', () => {
  let testDirectory;
  beforeEach(async () => {
    testDirectory = tmpDirectory('google/refreshTokens');
    vi.stubEnv('OROSHI_FOLDER_STATE', testDirectory);
    vi.spyOn(__, 'postToken').mockReturnValue({
      access_token: 'new-access',
      expires_in: 3599,
      scope: 'scope',
      token_type: 'Bearer',
    });
    vi.spyOn(Date, 'now').mockReturnValue(1_000_000);
  });
  afterEach(async () => {
    configInternals.account = null;
    vi.unstubAllEnvs();
    await remove(testDirectory);
  });

  it.each([
    { title: 'default account', account: null, file: 'tokens.json' },
    { title: 'named account', account: 'perso', file: 'tokens-perso.json' },
  ])(
    'rewrites the tokens file of the $title with the new access token',
    async ({ account, file }) => {
      configInternals.account = account;
      const path = `${testDirectory}/google/${file}`;
      await writeJson({ access_token: 'old', refresh_token: 'r/1' }, path);

      await refreshTokens({ access_token: 'old', refresh_token: 'r/1' });

      const actual = await readJson(path);
      expect(actual).toEqual({
        access_token: 'new-access',
        refresh_token: 'r/1',
        expires_in: 3599,
        expires_at: 1_000_000 + 3599 * 1000,
        scope: 'scope',
        token_type: 'Bearer',
      });
    },
  );

  it('asks the token endpoint with the refresh token', async () => {
    await refreshTokens({ access_token: 'old', refresh_token: 'r/1' });

    expect(__.postToken).toHaveBeenCalledWith({
      grant_type: 'refresh_token',
      refresh_token: 'r/1',
    });
  });

  it('returns the new tokens', async () => {
    const actual = await refreshTokens({
      access_token: 'old',
      refresh_token: 'r/1',
    });

    expect(actual).toHaveProperty('access_token', 'new-access');
    expect(actual).toHaveProperty('refresh_token', 'r/1');
  });
});
