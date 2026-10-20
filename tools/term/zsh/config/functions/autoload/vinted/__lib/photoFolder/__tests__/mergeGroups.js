import { mergeGroups } from '../mergeGroups.js';

describe('mergeGroups', () => {
  it.each([
    {
      title: 'keeps one group when an item appears in two batches',
      batches: [
        [{ series: 'Strange', number: '175', photos: ['a.jpg', 'b.jpg'] }],
        [{ series: 'Strange', number: '175', photos: ['a.jpg', 'b.jpg'] }],
      ],
      expected: [
        {
          series: 'Strange',
          number: '175',
          photos: ['a.jpg', 'b.jpg'],
          rotations: {},
          unsure: false,
        },
      ],
    },
    {
      title: 'keeps an item of 4 photos whole when a boundary falls inside it',
      batches: [
        [
          { series: 'Dune', photos: ['p01.jpg'] },
          { series: 'Strange', number: '175', photos: ['p03.jpg', 'p04.jpg'] },
        ],
        [
          {
            series: 'Strange',
            number: '175',
            photos: ['p03.jpg', 'p04.jpg', 'p05.jpg', 'p06.jpg'],
          },
        ],
      ],
      expected: [
        {
          series: 'Dune',
          photos: ['p01.jpg'],
          rotations: {},
          unsure: false,
        },
        {
          series: 'Strange',
          number: '175',
          photos: ['p03.jpg', 'p04.jpg', 'p05.jpg', 'p06.jpg'],
          rotations: {},
          unsure: false,
        },
      ],
    },
    {
      title: 'takes the identification of the largest group',
      batches: [
        [{ series: 'Stran', photos: ['a.jpg'], unsure: true }],
        [{ series: 'Strange', photos: ['a.jpg', 'b.jpg'], unsure: false }],
      ],
      expected: [
        {
          series: 'Strange',
          photos: ['a.jpg', 'b.jpg'],
          rotations: {},
          unsure: false,
        },
      ],
    },
    {
      title: 'keeps separate groups that share no photo',
      batches: [
        [
          { series: 'Dune', photos: ['a.jpg'] },
          { series: 'Strange', photos: ['b.jpg'] },
        ],
      ],
      expected: [
        { series: 'Dune', photos: ['a.jpg'], rotations: {}, unsure: false },
        { series: 'Strange', photos: ['b.jpg'], rotations: {}, unsure: false },
      ],
    },
    {
      title: 'joins the rotations of the merged groups',
      batches: [
        [
          {
            series: 'Dune',
            photos: ['a.jpg', 'b.jpg'],
            rotations: { 'a.jpg': 'left' },
          },
        ],
        [
          {
            series: 'Dune',
            photos: ['a.jpg', 'b.jpg'],
            rotations: { 'b.jpg': 'right' },
          },
        ],
      ],
      expected: [
        {
          series: 'Dune',
          photos: ['a.jpg', 'b.jpg'],
          rotations: { 'a.jpg': 'left', 'b.jpg': 'right' },
          unsure: false,
        },
      ],
    },
    {
      title: 'merges a chain of groups that overlap one after the other',
      batches: [
        [{ series: 'Dune', photos: ['a.jpg', 'b.jpg'] }],
        [{ series: 'Dune', photos: ['c.jpg', 'd.jpg'] }],
        [{ series: 'Dune', photos: ['b.jpg', 'c.jpg'] }],
      ],
      expected: [
        {
          series: 'Dune',
          photos: ['a.jpg', 'b.jpg', 'c.jpg', 'd.jpg'],
          rotations: {},
          unsure: false,
        },
      ],
    },
  ])('$title', ({ batches, expected }) => {
    const actual = mergeGroups(batches);

    expect(actual).toEqual(expected);
  });
});
