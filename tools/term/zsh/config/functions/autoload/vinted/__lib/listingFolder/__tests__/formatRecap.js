import { formatRecap } from '../formatRecap.js';

describe('formatRecap', () => {
  it.each([
    {
      title: 'prints the uncertain prices before the totals',
      input: {
        count: 2,
        total: 7,
        uncertain: [{ title: 'Dune n°2', price: 4 }],
      },
      expected: [
        'Uncertain prices:',
        'Dune n°2: 4.00 €',
        '2 listings',
        'Total: 7.00 €',
      ].join('\n'),
    },
    {
      title: 'skips the uncertain section when every price is certain',
      input: { count: 1, total: 4, uncertain: [] },
      expected: '1 listing\nTotal: 4.00 €',
    },
    {
      title: 'prints a clear message when there is no draft listing',
      input: { count: 0, total: 0, uncertain: [] },
      expected: 'No draft listing found.',
    },
  ])('$title', ({ input, expected }) => {
    const actual = formatRecap(input);

    expect(actual).toEqual(expected);
  });
});
