import { remove, tmpDirectory, writeJson } from 'firost';
import { getConfig } from '../getConfig.js';
import { setAccount } from '../setAccount.js';

describe('setAccount', () => {
  let testDirectory;
  beforeEach(async () => {
    testDirectory = tmpDirectory('google/setAccount');
    vi.stubEnv('OROSHI_FOLDER_STATE', testDirectory);
    vi.stubEnv('OROSHI_GOOGLE_CLIENT_ID', 'client-id');
    vi.stubEnv('OROSHI_GOOGLE_CLIENT_SECRET', 'client-secret');
    await writeJson(
      { refresh_token: 'default-refresh' },
      `${testDirectory}/google/tokens.json`,
    );
    await writeJson(
      { refresh_token: 'perso-refresh' },
      `${testDirectory}/google/tokens-perso.json`,
    );
  });
  afterEach(async () => {
    setAccount();
    vi.unstubAllEnvs();
    await remove(testDirectory);
  });

  it.each([
    { title: 'a named account', input: 'perso', expected: 'perso-refresh' },
    { title: 'an empty value', input: '', expected: 'default-refresh' },
    { title: 'no value', input: undefined, expected: 'default-refresh' },
  ])('selects the right tokens for $title', async ({ input, expected }) => {
    setAccount('perso');
    setAccount(input);

    const actual = await getConfig();

    expect(actual).toHaveProperty('tokens', { refresh_token: expected });
  });
});
