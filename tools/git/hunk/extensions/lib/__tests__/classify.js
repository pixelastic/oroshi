import { classifyLines } from '../classify.js';

describe('classifyLines', () => {
  it.each([
    {
      title: 'purely added lines get + marker',
      changes: [{ hunkIndex: 0, kind: 'added', range: [3, 5] }],
      totalLines: 10,
      expected: new Map([
        [3, { marker: '+', hunkIndex: 0 }],
        [4, { marker: '+', hunkIndex: 0 }],
        [5, { marker: '+', hunkIndex: 0 }],
      ]),
    },
    {
      title: 'purely removed range marks next surviving line as -',
      changes: [{ hunkIndex: 0, kind: 'removed', range: [4, 4] }],
      totalLines: 10,
      expected: new Map([[4, { marker: '-', hunkIndex: 0 }]]),
    },
    {
      title:
        'added range adjacent to removed range in same hunk marks added lines as ~',
      changes: [
        { hunkIndex: 0, kind: 'removed', range: [2, 3] },
        { hunkIndex: 0, kind: 'added', range: [3, 5] },
      ],
      totalLines: 10,
      expected: new Map([
        [3, { marker: '~', hunkIndex: 0 }],
        [4, { marker: '~', hunkIndex: 0 }],
        [5, { marker: '~', hunkIndex: 0 }],
      ]),
    },
    {
      title: 'added range with no removed range in same hunk marks lines as +',
      changes: [
        { hunkIndex: 0, kind: 'added', range: [3, 4] },
        { hunkIndex: 1, kind: 'removed', range: [8, 8] },
      ],
      totalLines: 10,
      expected: new Map([
        [3, { marker: '+', hunkIndex: 0 }],
        [4, { marker: '+', hunkIndex: 0 }],
        [8, { marker: '-', hunkIndex: 1 }],
      ]),
    },
    {
      title:
        'added range with non-adjacent removed in same hunk still marks as +',
      changes: [
        { hunkIndex: 0, kind: 'removed', range: [1, 1] },
        { hunkIndex: 0, kind: 'added', range: [5, 6] },
      ],
      totalLines: 10,
      expected: new Map([
        [1, { marker: '-', hunkIndex: 0 }],
        [5, { marker: '+', hunkIndex: 0 }],
        [6, { marker: '+', hunkIndex: 0 }],
      ]),
    },
    {
      title: 'when a line would be both - and +, + wins',
      changes: [
        { hunkIndex: 0, kind: 'added', range: [3, 3] },
        { hunkIndex: 1, kind: 'removed', range: [3, 3] },
      ],
      totalLines: 10,
      expected: new Map([[3, { marker: '+', hunkIndex: 0 }]]),
    },
    {
      title: 'when a line would be both - and ~, ~ wins',
      changes: [
        { hunkIndex: 0, kind: 'removed', range: [3, 3] },
        { hunkIndex: 0, kind: 'added', range: [3, 4] },
        { hunkIndex: 1, kind: 'removed', range: [3, 3] },
      ],
      totalLines: 10,
      expected: new Map([
        [3, { marker: '~', hunkIndex: 0 }],
        [4, { marker: '~', hunkIndex: 0 }],
      ]),
    },
    {
      title:
        'removed range at end of file with no surviving line produces no - marker',
      changes: [{ hunkIndex: 0, kind: 'removed', range: [11, 11] }],
      totalLines: 10,
      expected: new Map(),
    },
    {
      title: 'multiple hunks are classified independently',
      changes: [
        { hunkIndex: 0, kind: 'added', range: [2, 3] },
        { hunkIndex: 1, kind: 'removed', range: [7, 7] },
        { hunkIndex: 1, kind: 'added', range: [7, 8] },
      ],
      totalLines: 10,
      expected: new Map([
        [2, { marker: '+', hunkIndex: 0 }],
        [3, { marker: '+', hunkIndex: 0 }],
        [7, { marker: '~', hunkIndex: 1 }],
        [8, { marker: '~', hunkIndex: 1 }],
      ]),
    },
  ])('$title', ({ changes, totalLines, expected }) => {
    const actual = classifyLines(changes, totalLines);
    expect(actual).toEqual(expected);
  });
});
