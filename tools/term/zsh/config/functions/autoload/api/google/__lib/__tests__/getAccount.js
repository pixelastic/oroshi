import { getAccount } from '../getAccount.js';
import { setAccount } from '../setAccount.js';

describe('getAccount', () => {
  afterEach(() => {
    setAccount();
  });

  it.each([
    { title: 'a named account', input: 'perso', expected: 'perso' },
    { title: 'an empty value', input: '', expected: null },
    { title: 'no value', input: undefined, expected: null },
  ])('returns the account set for $title', ({ input, expected }) => {
    setAccount('work');
    setAccount(input);

    const actual = getAccount();

    expect(actual).toEqual(expected);
  });
});
