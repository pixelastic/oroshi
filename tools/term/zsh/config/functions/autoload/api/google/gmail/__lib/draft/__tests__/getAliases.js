import { setAccount } from '@oroshi/google/setAccount.js';
import { getAliases } from '../getAliases.js';

describe('getAliases', () => {
  beforeEach(() => {
    vi.stubEnv('OROSHI_GMAIL_ALIASES', 'me@example.com,work@example.com');
    vi.stubEnv('OROSHI_GMAIL_ALIASES_PERSO', 'perso@example.com');
  });
  afterEach(() => {
    setAccount();
    vi.unstubAllEnvs();
  });

  it.each([
    {
      title: 'reads the default variable for the default account',
      account: null,
      expected: ['me@example.com', 'work@example.com'],
    },
    {
      title: 'reads the PERSO variable for the perso account',
      account: 'perso',
      expected: ['perso@example.com'],
    },
  ])('$title', ({ account, expected }) => {
    setAccount(account);

    const actual = getAliases();

    expect(actual).toEqual(expected);
  });

  it('trims the spaces around each address', () => {
    vi.stubEnv('OROSHI_GMAIL_ALIASES', ' me@example.com , work@example.com ');

    const actual = getAliases();

    expect(actual).toEqual(['me@example.com', 'work@example.com']);
  });

  it.each([
    { title: 'default', account: null, name: 'OROSHI_GMAIL_ALIASES' },
    { title: 'perso', account: 'perso', name: 'OROSHI_GMAIL_ALIASES_PERSO' },
  ])(
    'throws an error naming the variable when $title is missing',
    ({ account, name }) => {
      setAccount(account);
      vi.stubEnv(name, '');
      let actual = null;
      try {
        getAliases();
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GMAIL_ALIASES_MISSING');
      expect(actual).toHaveProperty('message', `Set ${name}`);
    },
  );
});
