import { __, parseBinArgs } from '../parseBinArgs.js';

describe('parseBinArgs', () => {
  let setAccount;
  beforeEach(() => {
    setAccount = vi.fn();
  });

  it.each([
    {
      title: 'the first positional argument as a string',
      args: ['925'],
      path: 'positional',
      expected: '925',
    },
    {
      title: 'the named flags in camelCase',
      args: ['--blueprint-file', 'a.json'],
      path: 'named.blueprintFile',
      expected: 'a.json',
    },
    {
      title: 'the raw positional array of minimist in _',
      args: ['925', 'extra', '--wait'],
      path: '_',
      expected: [925, 'extra'],
    },
    {
      title: 'the positional after a boolean flag declared to minimist',
      args: ['--wait', '925'],
      minimist: { boolean: ['wait'] },
      path: 'positional',
      expected: '925',
    },
    {
      title: 'the boolean flag declared to minimist as true',
      args: ['--wait', '925'],
      minimist: { boolean: ['wait'] },
      path: 'named.wait',
      expected: true,
    },
    {
      title: 'the string flag declared to minimist as a string',
      args: ['--name', '2026'],
      minimist: { string: ['name'] },
      path: 'named.name',
      expected: '2026',
    },
  ])('returns $title', ({ args, minimist, path, expected }) => {
    vi.spyOn(__, 'getArgs').mockReturnValue(args);

    const actual = parseBinArgs({ setAccount, minimist });

    expect(actual).toHaveProperty(path, expected);
  });

  it('returns undefined as positional when there is none', () => {
    vi.spyOn(__, 'getArgs').mockReturnValue(['--wait']);

    const actual = parseBinArgs({ setAccount });

    expect(actual.positional).toBeUndefined();
  });

  it('passes the account to setAccount and removes it from named', () => {
    vi.spyOn(__, 'getArgs').mockReturnValue(['925', '--account', 'perso']);

    const actual = parseBinArgs({ setAccount });

    expect(setAccount).toHaveBeenCalledWith('perso');
    expect(actual.named).not.toHaveProperty('account');
  });

  it('calls setAccount with undefined without --account', () => {
    vi.spyOn(__, 'getArgs').mockReturnValue(['925']);

    parseBinArgs({ setAccount });

    expect(setAccount).toHaveBeenCalledWith(undefined);
  });
});
