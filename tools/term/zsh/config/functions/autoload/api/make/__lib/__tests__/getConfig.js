import { __, getConfig } from '../getConfig.js';

describe('getConfig', () => {
  beforeEach(() => {
    vi.stubEnv('MAKE_DOT_COM_API_KEY', 'default-key');
    vi.stubEnv('MAKE_DOT_COM_TEAM_ID', '1');
    vi.stubEnv('MAKE_DOT_COM_ZONE', 'eu2');
    vi.stubEnv('MAKE_DOT_COM_API_KEY_PERSO', 'perso-key');
    vi.stubEnv('MAKE_DOT_COM_TEAM_ID_PERSO', '2');
    vi.stubEnv('MAKE_DOT_COM_ZONE_PERSO', 'us1');
  });
  afterEach(() => {
    __.account = null;
    vi.unstubAllEnvs();
  });

  it.each([
    {
      title: 'default account',
      input: null,
      expected: { key: 'default-key', teamId: '1', zone: 'eu2' },
    },
    {
      title: 'named account',
      input: 'perso',
      expected: { key: 'perso-key', teamId: '2', zone: 'us1' },
    },
  ])(
    'returns the key, the team ID and the zone of the $title',
    async ({ input, expected }) => {
      __.account = input;

      const actual = await getConfig();

      expect(actual).toEqual(expected);
    },
  );

  it.each([
    { variable: 'MAKE_DOT_COM_API_KEY' },
    { variable: 'MAKE_DOT_COM_TEAM_ID' },
    { variable: 'MAKE_DOT_COM_ZONE' },
  ])('throws when $variable is empty', async ({ variable }) => {
    vi.stubEnv(variable, '');

    let actual = null;
    try {
      await getConfig();
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'MAKE_CREDENTIALS_MISSING');
    expect(actual).toHaveProperty('message', `Set ${variable}`);
  });
});
