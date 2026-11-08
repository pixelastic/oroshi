import { countGraphemes } from '../countGraphemes.js';

describe('countGraphemes', () => {
  it.each([
    { title: 'plain text', input: 'Hello', expected: 5 },
    { title: 'accents', input: 'Café', expected: 4 },
    { title: 'a ZWJ family emoji', input: '👨‍👩‍👧‍👦', expected: 1 },
  ])('counts $title', ({ input, expected }) => {
    expect(countGraphemes(input)).toEqual(expected);
  });
});
