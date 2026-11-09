import { toLimit } from '../toLimit.js';

describe('toLimit', () => {
  it.each([
    { title: 'a number', input: 5, expected: 5 },
    { title: 'a numeric string', input: '5', expected: 5 },
  ])('returns the limit from $title', ({ input, expected }) => {
    const actual = toLimit(input);

    expect(actual).toEqual(expected);
  });

  it.each([
    { title: 'zero', input: 0, expected: '0' },
    { title: 'negative', input: -1, expected: '-1' },
    { title: 'a decimal', input: 1.5, expected: '1.5' },
    { title: 'not a number', input: 'ten', expected: 'ten' },
    { title: 'empty', input: '', expected: '' },
  ])('throws when the limit is $title', ({ input, expected }) => {
    let actual = null;
    try {
      toLimit(input);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_INVALID_ARGUMENT');
    expect(actual).toHaveProperty(
      'message',
      `--limit must be a positive integer, got "${expected}"`,
    );
  });
});
