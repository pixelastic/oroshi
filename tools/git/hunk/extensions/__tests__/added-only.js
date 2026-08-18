import addedOnly, { __ } from '../added-only.js';

/**
 * Build a mock ExtensionFileViewInput
 * @param {string|null} doc - Document content readDocument returns
 * @returns {object} Mock input
 */
function mockInput(doc) {
  return {
    changes: [],
    readDocument: vi.fn().mockReturnValue(doc),
    signal: new AbortController().signal,
    width: 80,
    file: { id: 'test', path: 'test.js' },
  };
}

describe('addedOnly', () => {
  let view;
  const colors = {
    colorAdded: '#00ff00',
    colorModified: '#ff00ff',
    colorRemoved: '#ff0000',
  };

  beforeEach(() => {
    const hunk = {
      config: colors,
      registerFileView: vi.fn(),
      registerCommand: vi.fn(),
      log: vi.fn(),
    };
    addedOnly(hunk);
    view = hunk.registerFileView.mock.calls[0][0];
  });

  it('matches all files', () => {
    expect(view.matches({})).toBe(true);
  });

  it('returns null when new-side document is unavailable', async () => {
    const actual = await view.layout(mockInput(null));
    expect(actual).toBeNull();
  });

  it('returns empty layout when no annotations', async () => {
    vi.spyOn(__, 'classifyLines').mockReturnValue(new Map());
    const actual = await view.layout(mockInput('hello'));
    expect(actual).toEqual({ rows: [], hunkRows: [] });
  });

  describe('single hunk with context', () => {
    let layout;
    beforeEach(async () => {
      vi.spyOn(__, 'classifyLines').mockReturnValue(
        new Map([[2, { marker: '+', hunkIndex: 0 }]]),
      );
      vi.spyOn(__, 'buildLayout').mockReturnValue([
        { type: 'line', lineNumber: 1, marker: null, content: 'ctx' },
        { type: 'line', lineNumber: 2, marker: '+', content: 'added' },
        { type: 'line', lineNumber: 3, marker: null, content: 'ctx' },
      ]);
      layout = await view.layout(mockInput('ctx\nadded\nctx'));
    });

    it('produces one row per descriptor', () => {
      expect(layout.rows).toHaveLength(3);
    });

    it('sets line ids from line numbers', () => {
      expect(layout.rows[0].id).toBe('line-1');
      expect(layout.rows[1].id).toBe('line-2');
    });

    it('sets sourceRanges to new-side single-line ranges', () => {
      expect(layout.rows[1].sourceRanges).toEqual([
        { side: 'new', range: [2, 2] },
      ]);
    });

    it('uses added tone for + marker in fallback spans', () => {
      expect(layout.rows[1].spans[0]).toEqual({ text: '+ ', tone: 'added' });
    });

    it('uses muted tone for line number', () => {
      expect(layout.rows[1].spans[1]).toEqual({ text: '2 ', tone: 'muted' });
    });

    it('has no tone on content span', () => {
      expect(layout.rows[1].spans[2]).toEqual({ text: 'added' });
    });

    it('has no marker text for context lines', () => {
      expect(layout.rows[0].spans[0]).toEqual({ text: '  ' });
    });

    it('line rows have no component', () => {
      expect(layout.rows[1].component).toBeUndefined();
    });

    it('maps single hunk to all rows', () => {
      expect(layout.hunkRows).toEqual([{ startRow: 0, endRow: 2 }]);
    });
  });

  describe('two hunks with separator', () => {
    let layout;
    beforeEach(async () => {
      vi.spyOn(__, 'classifyLines').mockReturnValue(
        new Map([
          [2, { marker: '+', hunkIndex: 0 }],
          [10, { marker: '~', hunkIndex: 1 }],
        ]),
      );
      vi.spyOn(__, 'buildLayout').mockReturnValue([
        { type: 'line', lineNumber: 1, marker: null, content: 'a' },
        { type: 'line', lineNumber: 2, marker: '+', content: 'b' },
        { type: 'line', lineNumber: 3, marker: null, content: 'c' },
        { type: 'separator' },
        { type: 'line', lineNumber: 9, marker: null, content: 'd' },
        { type: 'line', lineNumber: 10, marker: '~', content: 'e' },
        { type: 'line', lineNumber: 11, marker: null, content: 'f' },
      ]);
      layout = await view.layout(mockInput('x\n'.repeat(15)));
    });

    it('separator has muted ··· spans', () => {
      expect(layout.rows[3].spans).toEqual([{ text: '···', tone: 'muted' }]);
    });

    it('separator id uses row index', () => {
      expect(layout.rows[3].id).toBe('separator-3');
    });

    it('separator has no sourceRanges', () => {
      expect(layout.rows[3].sourceRanges).toBeUndefined();
    });

    it('separator has no component', () => {
      expect(layout.rows[3].component).toBeUndefined();
    });

    it('maps each hunk to its row range excluding separator', () => {
      expect(layout.hunkRows).toEqual([
        { startRow: 0, endRow: 2 },
        { startRow: 4, endRow: 6 },
      ]);
    });

    it('right-pads line numbers to max width', () => {
      // Max line number is 11 (2 digits), so line 2 → ' 2 '
      expect(layout.rows[1].spans[1]).toEqual({
        text: ' 2 ',
        tone: 'muted',
      });
      expect(layout.rows[5].spans[1]).toEqual({
        text: '10 ',
        tone: 'muted',
      });
    });
  });

  describe('marker tones', () => {
    it.each([
      { marker: '+', expectedTone: 'added' },
      { marker: '~', expectedTone: 'added' },
      { marker: '-', expectedTone: 'removed' },
    ])(
      '$marker marker uses $expectedTone tone',
      async ({ marker, expectedTone }) => {
        vi.spyOn(__, 'classifyLines').mockReturnValue(
          new Map([[1, { marker, hunkIndex: 0 }]]),
        );
        vi.spyOn(__, 'buildLayout').mockReturnValue([
          { type: 'line', lineNumber: 1, marker, content: 'x' },
        ]);
        const result = await view.layout(mockInput('x'));
        expect(result.rows[0].spans[0].tone).toBe(expectedTone);
      },
    );
  });
});
