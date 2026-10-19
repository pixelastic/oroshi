import { summarizePrices } from '../summarizePrices.js';

describe('summarizePrices', () => {
  it.each([
    { title: 'odd count', input: [3, 1, 2], expected: 2 },
    { title: 'even count', input: [1, 2, 3, 10], expected: 2.5 },
    { title: 'single price', input: [7], expected: 7 },
  ])('returns the median for an $title', ({ input, expected }) => {
    const actual = summarizePrices(input);

    expect(actual).toHaveProperty('median', expected);
  });

  it('returns the count, min, max and quartiles', () => {
    const actual = summarizePrices([5, 1, 4, 2, 3]);

    expect(actual).toEqual({
      count: 5,
      min: 1,
      max: 5,
      median: 3,
      firstQuartile: 2,
      thirdQuartile: 4,
    });
  });

  it('ignores the input order', () => {
    const input = [4, 1, 6, 3, 5, 2];

    const actual = summarizePrices(input);

    const expected = summarizePrices([1, 2, 3, 4, 5, 6]);
    expect(actual).toEqual(expected);
  });

  it('does not mutate the input', () => {
    const input = [3, 1, 2];

    summarizePrices(input);

    expect(input).toEqual([3, 1, 2]);
  });

  it('throws a clear error for an empty list', () => {
    let actual = null;
    try {
      summarizePrices([]);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'VINTED_PRICE_NO_RESULT');
    expect(actual).toHaveProperty(
      'message',
      'No listing found, no price to summarize',
    );
  });
});
