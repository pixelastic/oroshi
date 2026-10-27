import { tokensPath } from '../tokensPath.js';

describe('tokensPath', () => {
  beforeEach(() => {
    vi.stubEnv('OROSHI_FOLDER_STATE', '/state');
  });
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it.each([
    { title: 'no account', input: undefined, expected: 'tokens.json' },
    { title: 'an empty account', input: '', expected: 'tokens.json' },
    { title: 'the default account', input: 'default', expected: 'tokens.json' },
    { title: 'a named account', input: 'perso', expected: 'tokens-perso.json' },
  ])('returns the path of $title', ({ input, expected }) => {
    const actual = tokensPath(input);

    expect(actual).toEqual(`/state/google/${expected}`);
  });
});
