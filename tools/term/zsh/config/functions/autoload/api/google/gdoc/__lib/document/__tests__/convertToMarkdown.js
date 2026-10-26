import { __, convertToMarkdown } from '../convertToMarkdown.js';

// Helper to build a Google Docs paragraph element
/**
 * Build a Google Docs text run element
 * @param {string} content - Text content
 * @param {object} style - Text style overrides
 * @returns {object} Text run element
 */
function textRun(content, style = {}) {
  return { textRun: { content, textStyle: style } };
}
/**
 * Build a Google Docs paragraph element
 * @param {object[]} elements - Paragraph elements
 * @param {string} styleType - Named style type
 * @param {object|null} bullet - Bullet configuration
 * @returns {object} Paragraph element
 */
function paragraph(elements, styleType = 'NORMAL_TEXT', bullet = null) {
  const para = {
    paragraph: {
      elements,
      paragraphStyle: { namedStyleType: styleType },
    },
  };
  if (bullet) {
    para.paragraph.bullet = bullet;
  }
  return para;
}

describe('convertToMarkdown', () => {
  const richDoc = {
    body: {
      content: [
        paragraph([textRun('Title\n')], 'HEADING_1'),
        paragraph([textRun('Subtitle\n')], 'HEADING_2'),
        paragraph([textRun('Some ')], 'NORMAL_TEXT'),
        paragraph(
          [
            textRun('Some '),
            textRun('bold', { bold: true }),
            textRun(' text\n'),
          ],
          'NORMAL_TEXT',
        ),
        paragraph(
          [
            textRun('Some '),
            textRun('italic', { italic: true }),
            textRun(' text\n'),
          ],
          'NORMAL_TEXT',
        ),
        paragraph(
          [
            textRun('Click '),
            textRun('here', { link: { url: 'https://example.com' } }),
            textRun(' for info\n'),
          ],
          'NORMAL_TEXT',
        ),
        paragraph([textRun('Bullet one\n')], 'NORMAL_TEXT', {
          listId: 'list1',
          nestingLevel: 0,
        }),
        paragraph([textRun('Bullet two\n')], 'NORMAL_TEXT', {
          listId: 'list1',
          nestingLevel: 0,
        }),
        paragraph([textRun('First\n')], 'NORMAL_TEXT', {
          listId: 'list2',
          nestingLevel: 0,
        }),
        paragraph([textRun('Second\n')], 'NORMAL_TEXT', {
          listId: 'list2',
          nestingLevel: 0,
        }),
        paragraph([textRun('Plain paragraph\n')], 'NORMAL_TEXT'),
      ],
    },
    lists: {
      list1: {
        listProperties: {
          nestingLevels: [{ glyphType: undefined }],
        },
      },
      list2: {
        listProperties: {
          nestingLevels: [{ glyphType: 'DECIMAL' }],
        },
      },
    },
  };

  it.each([
    { title: 'HEADING_1 → #', expected: '# Title' },
    { title: 'HEADING_2 → ##', expected: '## Subtitle' },
    { title: 'bold → **bold**', expected: '**bold**' },
    { title: 'italic → *italic*', expected: '*italic*' },
    { title: 'link → [text](url)', expected: '[here](https://example.com)' },
    {
      title: 'unordered list → bullets',
      expected: '- Bullet one\n- Bullet two',
    },
    { title: 'ordered list → numbers', expected: '1. First\n2. Second' },
    {
      title: 'paragraphs separated by blank lines',
      expected: '\nPlain paragraph',
    },
    {
      title: 'blank line after H1',
      expected: '# Title\n\n',
    },
    {
      title: 'blank line before and after H2',
      expected: '\n## Subtitle\n\n',
    },
  ])('$title', ({ expected }) => {
    const { markdown } = convertToMarkdown(richDoc);
    expect(markdown).toContain(expected);
  });

  it.each([
    { input: 'HEADING_3', expected: '### ' },
    { input: 'HEADING_4', expected: '#### ' },
    { input: 'HEADING_5', expected: '##### ' },
    { input: 'HEADING_6', expected: '###### ' },
  ])('$input → correct markdown prefix', ({ input, expected }) => {
    const doc = {
      body: { content: [paragraph([textRun('Text\n')], input)] },
      lists: {},
    };
    const { markdown } = convertToMarkdown(doc);
    expect(markdown).toEqual(`${expected}Text\n\n`);
  });

  it('inline images use source URL in markdown', () => {
    const doc = {
      body: {
        content: [
          {
            paragraph: {
              elements: [{ inlineObjectElement: { inlineObjectId: 'img1' } }],
              paragraphStyle: { namedStyleType: 'NORMAL_TEXT' },
            },
          },
        ],
      },
      inlineObjects: {
        img1: {
          inlineObjectProperties: {
            embeddedObject: {
              title: 'diagram',
              imageProperties: {
                contentUri: 'https://example.com/img.png',
              },
            },
          },
        },
      },
      lists: {},
    };
    const { markdown, images } = convertToMarkdown(doc);
    expect(markdown).toContain('![diagram](https://example.com/img.png)');
    expect(images).toEqual([{ contentUri: 'https://example.com/img.png' }]);
  });
});

describe('elementsToMarkdown', () => {
  it('replaces non-breaking spaces with regular spaces', () => {
    const elements = [
      { textRun: { content: 'hello\u00A0world\n', textStyle: {} } },
    ];
    const actual = __.elementsToMarkdown(elements);
    expect(actual).toEqual('hello world');
  });

  it('inline image produces ![alt](source-url)', () => {
    const elements = [{ inlineObjectElement: { inlineObjectId: 'obj1' } }];
    const inlineObjects = {
      obj1: {
        inlineObjectProperties: {
          embeddedObject: {
            description: 'A photo',
            imageProperties: { contentUri: 'https://img.test/1.png' },
          },
        },
      },
    };
    const images = [];
    const actual = __.elementsToMarkdown(elements, inlineObjects, images);
    expect(actual).toEqual('![A photo](https://img.test/1.png)');
    expect(images).toEqual([{ contentUri: 'https://img.test/1.png' }]);
  });
});

describe('tableToMarkdown', () => {
  /**
   * Build a table cell with text content
   * @param {...string} texts - Cell text values
   * @returns {object} Table cell element
   */
  function cell(...texts) {
    return {
      content: [
        {
          paragraph: {
            elements: texts.map((t) => ({
              textRun: { content: `${t}\n`, textStyle: {} },
            })),
          },
        },
      ],
    };
  }

  it('converts a 2x2 table to markdown', () => {
    const table = {
      tableRows: [
        { tableCells: [cell('Header A'), cell('Header B')] },
        { tableCells: [cell('Val 1'), cell('Val 2')] },
      ],
    };
    const actual = __.tableToMarkdown(table, {}, []);
    expect(actual).toEqual(
      ['| Header A | Header B |', '| --- | --- |', '| Val 1 | Val 2 |'].join(
        '\n',
      ),
    );
  });

  it('handles bold text inside cells', () => {
    const boldCell = {
      content: [
        {
          paragraph: {
            elements: [
              { textRun: { content: 'bold\n', textStyle: { bold: true } } },
            ],
          },
        },
      ],
    };
    const table = {
      tableRows: [{ tableCells: [boldCell, cell('plain')] }],
    };
    const actual = __.tableToMarkdown(table, {}, []);
    expect(actual).toContain('| **bold** | plain |');
  });
});

describe('wrapText', () => {
  it.each([
    {
      title: 'wraps long text at word boundaries',
      input: 'one two three four five six seven eight nine ten',
      width: 20,
      expected: 'one two three four\nfive six seven eight\nnine ten',
    },
    {
      title: 'keeps short text on one line',
      input: 'short',
      width: 80,
      expected: 'short',
    },
    {
      title: 'does not break a single long word',
      input: 'a'.repeat(100),
      width: 80,
      expected: 'a'.repeat(100),
    },
  ])('$title', ({ input, width, expected }) => {
    const actual = __.wrapText(input, width);
    expect(actual).toEqual(expected);
  });
});
