import { __, getConfig } from '../getConfig.js';

describe('getConfig', () => {
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
    __.account = null;
    vi.unstubAllEnvs();
  });

  it.each([
    {
      title: 'default account',
      input: null,
      expected: {
        email: 'me@work.com',
        token: 'default-token',
        cloudId: 'default-cloud',
        domain: 'work.atlassian.net',
      },
    },
    {
      title: 'named account',
      input: 'perso',
      expected: {
        email: 'me@home.com',
        token: 'perso-token',
        cloudId: 'perso-cloud',
        domain: 'home.atlassian.net',
      },
    },
  ])('returns the credentials of the $title', async ({ input, expected }) => {
    __.account = input;

    const actual = await getConfig();

    expect(actual).toEqual(expected);
  });

  it.each([
    { variable: 'CONFLUENCE_EMAIL' },
    { variable: 'CONFLUENCE_TOKEN' },
    { variable: 'CONFLUENCE_CLOUD_ID' },
    { variable: 'CONFLUENCE_DOMAIN' },
  ])('throws when $variable is empty', async ({ variable }) => {
    vi.stubEnv(variable, '');

    let actual = null;
    try {
      await getConfig();
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CONFLUENCE_CREDENTIALS_MISSING');
    expect(actual).toHaveProperty('message', `Set ${variable}`);
  });

  it('names the suffixed variable in the error of a named account', async () => {
    __.account = 'perso';
    vi.stubEnv('CONFLUENCE_TOKEN_PERSO', '');

    let actual = null;
    try {
      await getConfig();
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'Set CONFLUENCE_TOKEN_PERSO');
  });
});
