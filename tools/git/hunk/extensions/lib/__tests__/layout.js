import { buildLayout } from '../layout.js';

/**
 * Generate an array of N lines
 * @param {number} n - Number of lines
 * @returns {string[]} Array of line strings
 */
function makeLines(n) {
  return Array.from({ length: n }, (_, i) => `line ${i + 1}`);
}

describe('buildLayout', () => {
  it.each([
    {
      title: 'single hunk emits 3 context lines above and below changed lines',
      lines: makeLines(10),
      annotations: new Map([[5, { marker: '+', hunkIndex: 0 }]]),
      expected: [
        { type: 'line', lineNumber: 2, marker: null, content: 'line 2' },
        { type: 'line', lineNumber: 3, marker: null, content: 'line 3' },
        { type: 'line', lineNumber: 4, marker: null, content: 'line 4' },
        { type: 'line', lineNumber: 5, marker: '+', content: 'line 5' },
        { type: 'line', lineNumber: 6, marker: null, content: 'line 6' },
        { type: 'line', lineNumber: 7, marker: null, content: 'line 7' },
        { type: 'line', lineNumber: 8, marker: null, content: 'line 8' },
      ],
    },
    {
      title: 'two hunks far apart produce a separator between them',
      lines: makeLines(20),
      annotations: new Map([
        [5, { marker: '+', hunkIndex: 0 }],
        [15, { marker: '~', hunkIndex: 1 }],
      ]),
      expected: [
        { type: 'line', lineNumber: 2, marker: null, content: 'line 2' },
        { type: 'line', lineNumber: 3, marker: null, content: 'line 3' },
        { type: 'line', lineNumber: 4, marker: null, content: 'line 4' },
        { type: 'line', lineNumber: 5, marker: '+', content: 'line 5' },
        { type: 'line', lineNumber: 6, marker: null, content: 'line 6' },
        { type: 'line', lineNumber: 7, marker: null, content: 'line 7' },
        { type: 'line', lineNumber: 8, marker: null, content: 'line 8' },
        { type: 'separator' },
        { type: 'line', lineNumber: 12, marker: null, content: 'line 12' },
        { type: 'line', lineNumber: 13, marker: null, content: 'line 13' },
        { type: 'line', lineNumber: 14, marker: null, content: 'line 14' },
        { type: 'line', lineNumber: 15, marker: '~', content: 'line 15' },
        { type: 'line', lineNumber: 16, marker: null, content: 'line 16' },
        { type: 'line', lineNumber: 17, marker: null, content: 'line 17' },
        { type: 'line', lineNumber: 18, marker: null, content: 'line 18' },
      ],
    },
    {
      title:
        'two hunks close enough merge into one contiguous range with no separator',
      lines: makeLines(20),
      annotations: new Map([
        [5, { marker: '+', hunkIndex: 0 }],
        [9, { marker: '~', hunkIndex: 1 }],
      ]),
      expected: [
        { type: 'line', lineNumber: 2, marker: null, content: 'line 2' },
        { type: 'line', lineNumber: 3, marker: null, content: 'line 3' },
        { type: 'line', lineNumber: 4, marker: null, content: 'line 4' },
        { type: 'line', lineNumber: 5, marker: '+', content: 'line 5' },
        { type: 'line', lineNumber: 6, marker: null, content: 'line 6' },
        { type: 'line', lineNumber: 7, marker: null, content: 'line 7' },
        { type: 'line', lineNumber: 8, marker: null, content: 'line 8' },
        { type: 'line', lineNumber: 9, marker: '~', content: 'line 9' },
        { type: 'line', lineNumber: 10, marker: null, content: 'line 10' },
        { type: 'line', lineNumber: 11, marker: null, content: 'line 11' },
        { type: 'line', lineNumber: 12, marker: null, content: 'line 12' },
      ],
    },
    {
      title: 'context is clamped at file start (no negative line numbers)',
      lines: makeLines(10),
      annotations: new Map([[2, { marker: '+', hunkIndex: 0 }]]),
      expected: [
        { type: 'line', lineNumber: 1, marker: null, content: 'line 1' },
        { type: 'line', lineNumber: 2, marker: '+', content: 'line 2' },
        { type: 'line', lineNumber: 3, marker: null, content: 'line 3' },
        { type: 'line', lineNumber: 4, marker: null, content: 'line 4' },
        { type: 'line', lineNumber: 5, marker: null, content: 'line 5' },
      ],
    },
    {
      title: 'context is clamped at file end (no lines past document length)',
      lines: makeLines(10),
      annotations: new Map([[9, { marker: '-', hunkIndex: 0 }]]),
      expected: [
        { type: 'line', lineNumber: 6, marker: null, content: 'line 6' },
        { type: 'line', lineNumber: 7, marker: null, content: 'line 7' },
        { type: 'line', lineNumber: 8, marker: null, content: 'line 8' },
        { type: 'line', lineNumber: 9, marker: '-', content: 'line 9' },
        { type: 'line', lineNumber: 10, marker: null, content: 'line 10' },
      ],
    },
    {
      title:
        'context lines have null marker, changed lines have their annotation marker',
      lines: makeLines(10),
      annotations: new Map([
        [5, { marker: '+', hunkIndex: 0 }],
        [6, { marker: '~', hunkIndex: 0 }],
      ]),
      expected: [
        { type: 'line', lineNumber: 2, marker: null, content: 'line 2' },
        { type: 'line', lineNumber: 3, marker: null, content: 'line 3' },
        { type: 'line', lineNumber: 4, marker: null, content: 'line 4' },
        { type: 'line', lineNumber: 5, marker: '+', content: 'line 5' },
        { type: 'line', lineNumber: 6, marker: '~', content: 'line 6' },
        { type: 'line', lineNumber: 7, marker: null, content: 'line 7' },
        { type: 'line', lineNumber: 8, marker: null, content: 'line 8' },
        { type: 'line', lineNumber: 9, marker: null, content: 'line 9' },
      ],
    },
    {
      title: 'empty annotations produce empty layout',
      lines: makeLines(10),
      annotations: new Map(),
      expected: [],
    },
  ])('$title', ({ lines, annotations, expected }) => {
    const actual = buildLayout(lines, annotations);
    expect(actual).toEqual(expected);
  });
});
