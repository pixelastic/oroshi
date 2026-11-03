import { getConfig } from '../getConfig.js';
import { setAccount } from '../setAccount.js';

describe('setAccount', () => {
  beforeEach(() => {
    vi.stubEnv('CONFLUENCE_EMAIL', 'me@work.com');
    vi.stubEnv('CONFLUENCE_TOKEN', 'default-token');
    vi.stubEnv('CONFLUENCE_CLOUD_ID', 'default-cloud');
    vi.stubEnv('CONFLUENCE_DOMAIN', 'work.atlassian.net');
    vi.stubEnv('CONFLUENCE_EMAIL_PERSO', 'me@home.com');
    vi.stubEnv('CONFLUENCE_TOKEN_PERSO', 'perso-token');
    vi.stubEnv('CONFLUENCE_CLOUD_ID_PERSO', 'perso-cloud');
    vi.stubEnv('CONFLUENCE_DOMAIN_PERSO', 'home.atlassian.net');
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

      expect(actual).toHaveProperty('token', expected);
    },
  );
});
