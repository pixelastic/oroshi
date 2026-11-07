import { remove, tmpDirectory, writeJson } from 'firost';
import { getConfig } from '../getConfig.js';
import { setAccount } from '../setAccount.js';

describe('setAccount', () => {
  let testDirectory;
  beforeEach(async () => {
    testDirectory = tmpDirectory('bluesky/setAccount');
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
    setAccount();
    vi.unstubAllEnvs();
    await remove(testDirectory);
  });

  it.each([
    { title: 'a named account', input: 'test', expected: 'test-session' },
    { title: 'an empty value', input: '', expected: 'default-session' },
    { title: 'no value', input: undefined, expected: 'default-session' },
  ])('selects the right tokens for $title', async ({ input, expected }) => {
    setAccount('test');
    setAccount(input);

    const actual = await getConfig();

    expect(actual).toEqual({ tokens: { session: expected } });
  });
});
