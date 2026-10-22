import { parseSoldIds } from '../parseSoldIds.js';

describe('parseSoldIds', () => {
  it.each([
    {
      title: 'item links',
      input:
        '<a href="/items/123-dune">Dune</a><a href="/items/456-asterix">Asterix</a>',
      expected: ['123', '456'],
    },
    {
      title: 'absolute links with a query',
      input:
        '<a href="https://www.vinted.fr/items/789-tintin?referrer=x">T</a>',
      expected: ['789'],
    },
    {
      title: 'the same item linked twice',
      input: '<a href="/items/123-dune">a</a><a href="/items/123-dune">b</a>',
      expected: ['123'],
    },
    {
      title: 'links without an id',
      input: '<a href="/items/new">New</a><a href="/member/12">Me</a>',
      expected: [],
    },
    { title: 'empty markup', input: '', expected: [] },
  ])('reads $title', ({ input, expected }) => {
    const actual = parseSoldIds(input);

    expect(actual).toEqual(expected);
  });
});
