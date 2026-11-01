import { __, parseBinArgs } from '../parseBinArgs.js';

describe('parseBinArgs', () => {
  let setAccount;
  beforeEach(() => {
    setAccount = vi.fn();
  });

  const options = {
    'blueprint-file': { type: 'string' },
    description: { type: 'string' },
    name: { type: 'string' },
    wait: { type: 'boolean' },
  };

  it('returns undefined as positional when there is none', () => {
    vi.spyOn(__, 'getArgs').mockReturnValue(['--wait']);

    const actual = parseBinArgs({ setAccount, options });

    expect(actual.positional).toBeUndefined();
  });

  it.each([
    {
      title: 'the first positional argument as a string',
      args: ['925'],
      path: 'positional',
      expected: '925',
    },
    {
      title: 'the raw positionals as strings in _',
      args: ['925', 'extra', '--wait'],
      path: '_',
      expected: ['925', 'extra'],
    },
    {
      title: 'the named flags in camelCase',
      args: ['--blueprint-file', 'a.json'],
      path: 'named.blueprintFile',
      expected: 'a.json',
    },
    {
      title: 'a boolean flag as true',
      args: ['--wait', '925'],
      path: 'named.wait',
      expected: true,
    },
    {
      title: 'a value that starts with a dash after an equal sign',
      args: ['--description=- item'],
      path: 'named.description',
      expected: '- item',
    },
  ])('returns $title', ({ args, path, expected }) => {
    vi.spyOn(__, 'getArgs').mockReturnValue(args);

    const actual = parseBinArgs({ setAccount, options });

    expect(actual).toHaveProperty(path, expected);
  });

  it('passes the account to setAccount and removes it from named', () => {
    vi.spyOn(__, 'getArgs').mockReturnValue(['925', '--account', 'perso']);

    const actual = parseBinArgs({ setAccount, options });

    expect(setAccount).toHaveBeenCalledWith('perso');
    expect(actual.named).not.toHaveProperty('account');
  });

  it('calls setAccount with undefined without --account', () => {
    vi.spyOn(__, 'getArgs').mockReturnValue(['925']);

    parseBinArgs({ setAccount, options });

    expect(setAccount).toHaveBeenCalledWith(undefined);
  });

  it.each([
    {
      title: 'a value that starts with a dash after a space',
      args: ['--description', '- item'],
      expected: 'ERR_PARSE_ARGS_INVALID_OPTION_VALUE',
    },
    {
      title: 'a string flag without a value',
      args: ['--name'],
      expected: 'ERR_PARSE_ARGS_INVALID_OPTION_VALUE',
    },
    {
      title: 'an unknown flag',
      args: ['--unknown'],
      expected: 'ERR_PARSE_ARGS_UNKNOWN_OPTION',
    },
    {
      title: 'a boolean flag that receives a value',
      args: ['--wait=yes'],
      expected: 'ERR_PARSE_ARGS_INVALID_OPTION_VALUE',
    },
  ])('throws on $title', ({ args, expected }) => {
    vi.spyOn(__, 'getArgs').mockReturnValue(args);

    let actual = null;
    try {
      parseBinArgs({ setAccount, options });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', expected);
  });
});
