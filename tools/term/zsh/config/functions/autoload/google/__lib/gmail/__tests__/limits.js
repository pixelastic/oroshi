import { gmailLimits } from '../limits.js';

describe('gmailLimits', () => {
  it.each([
    { title: 'caps inbox threads', key: 'inbox', expected: 25 },
    { title: 'caps search results', key: 'search', expected: 50 },
  ])('$title', ({ key, expected }) => {
    const actual = gmailLimits[key];
    expect(actual).toEqual(expected);
  });
});
