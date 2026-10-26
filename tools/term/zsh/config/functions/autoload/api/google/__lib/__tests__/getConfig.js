import { remove, tmpDirectory, writeJson } from 'firost';
import { __, getConfig } from '../getConfig.js';

describe('getConfig', () => {
  let testDirectory;
  beforeEach(async () => {
    testDirectory = tmpDirectory('google/getConfig');
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
    __.account = null;
    vi.unstubAllEnvs();
    await remove(testDirectory);
  });

  it.each([
    { title: 'default account', input: null, expected: 'default-refresh' },
    { title: 'named account', input: 'perso', expected: 'perso-refresh' },
  ])(
    'returns the tokens and the client of the $title',
    async ({ input, expected }) => {
      __.account = input;

      const actual = await getConfig();

      expect(actual).toEqual({
        tokens: { refresh_token: expected },
        clientId: 'client-id',
        clientSecret: 'client-secret',
      });
    },
  );

  it.each([
    {
      title: 'default account',
      input: null,
      expected: 'run google-login',
    },
    {
      title: 'named account',
      input: 'work',
      expected: 'run google-login --account work',
    },
  ])(
    'throws when the tokens file of the $title is missing',
    async ({ input, expected }) => {
      __.account = input;
      await remove(`${testDirectory}/google/tokens.json`);

      let actual = null;
      try {
        await getConfig();
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GOOGLE_LOGIN_REQUIRED');
      expect(actual).toHaveProperty('message', expected);
    },
  );

  it.each([
    { title: 'client id', variable: 'OROSHI_GOOGLE_CLIENT_ID' },
    { title: 'client secret', variable: 'OROSHI_GOOGLE_CLIENT_SECRET' },
  ])('throws when the $title is empty', async ({ variable }) => {
    vi.stubEnv(variable, '');

    let actual = null;
    try {
      await getConfig();
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GOOGLE_CREDENTIALS_MISSING');
    expect(actual).toHaveProperty('message', `Set ${variable}`);
  });
});
