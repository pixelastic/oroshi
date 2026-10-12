import { getConfig } from '../getConfig.js';
import { setAccount } from '../setAccount.js';

describe('setAccount', () => {
  beforeEach(() => {
    vi.stubEnv('MAKE_DOT_COM_API_KEY', 'default-key');
    vi.stubEnv('MAKE_DOT_COM_TEAM_ID', '1');
    vi.stubEnv('MAKE_DOT_COM_ZONE', 'eu2');
    vi.stubEnv('MAKE_DOT_COM_API_KEY_PERSO', 'perso-key');
    vi.stubEnv('MAKE_DOT_COM_TEAM_ID_PERSO', '2');
    vi.stubEnv('MAKE_DOT_COM_ZONE_PERSO', 'us1');
  });
  afterEach(() => {
    setAccount();
    vi.unstubAllEnvs();
  });

  it.each([
    { title: 'a named account', input: 'perso', expected: 'perso-key' },
    { title: 'an empty value', input: '', expected: 'default-key' },
    { title: 'no value', input: undefined, expected: 'default-key' },
  ])(
    'selects the right credentials for $title',
    async ({ input, expected }) => {
      setAccount('perso');
      setAccount(input);

      const actual = await getConfig();

      expect(actual).toHaveProperty('key', expected);
    },
  );
});
