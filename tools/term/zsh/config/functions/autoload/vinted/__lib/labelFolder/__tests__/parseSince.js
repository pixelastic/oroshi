import { parseSince } from '../parseSince.js';

describe('parseSince', () => {
  const now = new Date('2026-10-22T12:00:00.000Z');

  it.each([
    { input: '5d', expected: '2026-10-17T12:00:00.000Z' },
    { input: '12h', expected: '2026-10-22T00:00:00.000Z' },
    { input: '30m', expected: '2026-10-22T11:30:00.000Z' },
    { input: '2026-10-20T08:00:00Z', expected: '2026-10-20T08:00:00.000Z' },
    { input: '2026-10-20', expected: '2026-10-20T00:00:00.000Z' },
  ])('parses $input', ({ input, expected }) => {
    const actual = parseSince(input, { now });

    expect(actual.toISOString()).toEqual(expected);
  });

  it.each([{ input: 'yesterday' }, { input: '' }, { input: '5 days' }])(
    'throws on "$input"',
    ({ input }) => {
      let actual = null;
      try {
        parseSince(input, { now });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'VINTED_LABEL_INVALID_SINCE');
    },
  );
});
