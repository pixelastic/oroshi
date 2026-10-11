import { __, getConfig } from '../getConfig.js';

describe('getConfig', () => {
  beforeEach(() => {
    vi.stubEnv('AIRTABLE_TOKEN', 'default-token');
    vi.stubEnv('AIRTABLE_TOKEN_PERSO', 'perso-token');
  });
  afterEach(() => {
    __.account = null;
    vi.unstubAllEnvs();
  });

  it.each([
    { title: 'default account', input: null, expected: 'default-token' },
    { title: 'named account', input: 'perso', expected: 'perso-token' },
  ])('returns the token of the $title', async ({ input, expected }) => {
    __.account = input;

    const actual = await getConfig();

    expect(actual).toEqual({ token: expected });
  });

  it('throws when the variable is empty', async () => {
    vi.stubEnv('AIRTABLE_TOKEN', '');

    let actual = null;
    try {
      await getConfig();
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_CREDENTIALS_MISSING');
    expect(actual).toHaveProperty('message', 'Set AIRTABLE_TOKEN');
  });
});
