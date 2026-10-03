import { gmailLimits } from '../limits.js';

describe('gmailLimits', () => {
  it.each([
    { title: 'fetches the whole inbox', key: 'inbox', expected: 100 },
    { title: 'caps search results', key: 'search', expected: 50 },
  ])('$title', ({ key, expected }) => {
    const actual = gmailLimits[key];
    expect(actual).toEqual(expected);
  });
});
