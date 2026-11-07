import { remove, tmpDirectory, writeJson } from 'firost';
import { __, getConfig } from '../getConfig.js';

describe('getConfig', () => {
  let testDirectory;
  beforeEach(async () => {
    testDirectory = tmpDirectory('bluesky/getConfig');
    vi.stubEnv('OROSHI_FOLDER_STATE', testDirectory);
    await writeJson(
      { session: 'default-session' },
      `${testDirectory}/bluesky/tokens.json`,
    );
    await writeJson(
      { session: 'test-session' },
      `${testDirectory}/bluesky/tokens-test.json`,
    );
  });
  afterEach(async () => {
    __.account = null;
    vi.unstubAllEnvs();
    await remove(testDirectory);
  });

  it.each([
    { title: 'default account', input: null, expected: 'default-session' },
    { title: 'test account', input: 'test', expected: 'test-session' },
  ])('returns the tokens of the $title', async ({ input, expected }) => {
    __.account = input;

    const actual = await getConfig();

    expect(actual).toEqual({ tokens: { session: expected } });
  });

  it.each([
    {
      title: 'default account',
      input: null,
      expected: 'run bluesky-login',
    },
    {
      title: 'test account',
      input: 'test',
      expected: 'run bluesky-login --account test',
    },
  ])(
    'throws when the tokens file of the $title is missing',
    async ({ input, expected }) => {
      __.account = input;
      await remove(`${testDirectory}/bluesky/tokens.json`);
      await remove(`${testDirectory}/bluesky/tokens-test.json`);

      let actual = null;
      try {
        await getConfig();
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'BLUESKY_LOGIN_REQUIRED');
      expect(actual).toHaveProperty('message', expected);
    },
  );
});
