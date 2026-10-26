import { loginCommand } from '../loginCommand.js';

describe('loginCommand', () => {
  it.each([
    { title: 'default account', input: null, expected: 'run google-login' },
    {
      title: 'named account',
      input: 'perso',
      expected: 'run google-login --account perso',
    },
  ])('returns the command of the $title', ({ input, expected }) => {
    const actual = loginCommand(input);

    expect(actual).toEqual(expected);
  });
});
