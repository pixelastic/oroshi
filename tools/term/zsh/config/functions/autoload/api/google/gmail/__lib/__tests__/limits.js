import { limits } from '../limits.js';

describe('limits', () => {
  it.each([
    { title: 'caps inbox Messages', key: 'inbox', expected: 25 },
    { title: 'caps search results', key: 'search', expected: 25 },
  ])('$title', ({ key, expected }) => {
    const actual = limits[key];
    expect(actual).toEqual(expected);
  });
});
