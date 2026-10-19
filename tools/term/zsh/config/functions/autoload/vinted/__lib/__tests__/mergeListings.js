import { mergeListings } from '../mergeListings.js';

describe('mergeListings', () => {
  it.each([
    {
      title: 'counts a listing once when two searches return it',
      input: [
        [
          { id: '1', price: 10 },
          { id: '2', price: 20 },
        ],
        [
          { id: '2', price: 20 },
          { id: '3', price: 30 },
        ],
      ],
      expected: [
        { id: '1', price: 10 },
        { id: '2', price: 20 },
        { id: '3', price: 30 },
      ],
    },
    {
      title: 'returns an empty list when no search returns a listing',
      input: [[], []],
      expected: [],
    },
  ])('$title', ({ input, expected }) => {
    const actual = mergeListings(input);

    expect(actual).toEqual(expected);
  });
});
