import { __, getConfig } from '../getConfig.js';

describe('getConfig', () => {
  beforeEach(() => {
    vi.stubEnv('CIRCLECI_TOKEN', 'default-token');
    vi.stubEnv('CIRCLECI_TOKEN_PERSO', 'perso-token');
  });
  afterEach(() => {
    __.account = null;
    vi.unstubAllEnvs();
  });

  it.each([
    {
      title: 'default account',
      input: null,
      expected: { token: 'default-token' },
    },
    {
      title: 'named account',
      input: 'perso',
      expected: { token: 'perso-token' },
    },
  ])('returns the token of the $title', async ({ input, expected }) => {
    __.account = input;

    const actual = await getConfig();

    expect(actual).toEqual(expected);
  });

  it('throws when the token is empty', async () => {
    vi.stubEnv('CIRCLECI_TOKEN', '');

    let actual = null;
    try {
      await getConfig();
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_CREDENTIALS_MISSING');
    expect(actual).toHaveProperty('message', 'Set CIRCLECI_TOKEN');
  });
});
