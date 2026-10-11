import { getConfig } from '../getConfig.js';
import { setAccount } from '../setAccount.js';

describe('setAccount', () => {
  beforeEach(() => {
    vi.stubEnv('AIRTABLE_TOKEN', 'default-token');
    vi.stubEnv('AIRTABLE_TOKEN_PERSO', 'perso-token');
  });
  afterEach(() => {
    setAccount();
    vi.unstubAllEnvs();
  });

  it.each([
    { title: 'a named account', input: 'perso', expected: 'perso-token' },
    { title: 'an empty value', input: '', expected: 'default-token' },
    { title: 'no value', input: undefined, expected: 'default-token' },
  ])(
    'selects the right credentials for $title',
    async ({ input, expected }) => {
      setAccount('perso');
      setAccount(input);

      const actual = await getConfig();

      expect(actual).toEqual({ token: expected });
    },
  );
});
