import { __, gdocs2md } from '../gdocs2md.js';

// Helper to build a Google Docs paragraph element
/**
 *
 * @param content
 * @param style
 */
function textRun(content, style = {}) {
  return { textRun: { content, textStyle: style } };
}
/**
 *
 * @param elements
 * @param styleType
 * @param bullet
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

describe('extractDocId', () => {
  it.each([
    {
      title: 'full Google Docs URL',
      input: 'https://docs.google.com/document/d/abc123xyz/edit',
      expected: 'abc123xyz',
    },
    {
      title: 'URL with hash fragment',
      input: 'https://docs.google.com/document/d/abc123xyz/edit#heading=h.1',
      expected: 'abc123xyz',
    },
    {
      title: 'bare document ID',
      input: 'abc123xyz',
      expected: 'abc123xyz',
    },
  ])('$title', ({ input, expected }) => {
    const actual = __.extractDocId(input);
    expect(actual).toEqual(expected);
  });
});

describe('slugify', () => {
  it.each([
    { input: 'Hello World', expected: 'hello-world' },
    { input: 'Café & Résumé', expected: 'cafe-resume' },
    { input: '  Spaces  Everywhere  ', expected: 'spaces-everywhere' },
    {
      input: 'Monolithic vs. Distributed Agents: How to Choose',
      expected: 'monolithic-vs-distributed-agents-how-to-choose',
    },
  ])('$input → $expected', ({ input, expected }) => {
    expect(__.slugify(input)).toEqual(expected);
  });
});

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
    const { markdown } = __.convertToMarkdown(richDoc);
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
    const { markdown } = __.convertToMarkdown(doc);
    expect(markdown).toEqual(`${expected}Text\n\n`);
  });

  it('collects inline images', () => {
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
    const { markdown, images } = __.convertToMarkdown(doc);
    expect(markdown).toContain('![diagram](image-1.png)');
    expect(images).toEqual([
      { contentUri: 'https://example.com/img.png', filename: 'image-1.png' },
    ]);
  });
});

describe('tableToMarkdown', () => {
  /**
   *
   * @param {...any} texts
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
  it('wraps long text at word boundaries', () => {
    const input = 'one two three four five six seven eight nine ten';
    const actual = __.wrapText(input, 20);
    expect(actual).toEqual(
      'one two three four\nfive six seven eight\nnine ten',
    );
  });

  it('keeps short text on one line', () => {
    expect(__.wrapText('short', 80)).toEqual('short');
  });

  it('does not break a single long word', () => {
    const longWord = 'a'.repeat(100);
    expect(__.wrapText(longWord, 80)).toEqual(longWord);
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

  it('converts inline image to markdown reference', () => {
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
    expect(actual).toEqual('![A photo](image-1.png)');
    expect(images).toHaveLength(1);
    expect(images[0].contentUri).toEqual('https://img.test/1.png');
  });
});

describe('gdocs2md', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getAuth').mockReturnValue({ credentials: 'mock' });
    vi.spyOn(__, 'fetchDoc').mockReturnValue({
      title: 'My Document',
      body: {
        content: [paragraph([textRun('Hello\n')], 'HEADING_1')],
      },
      lists: {},
    });
  });

  it('returns markdown, images, title, and slug', async () => {
    const actual = await gdocs2md('abc123');
    expect(actual.markdown).toEqual('# Hello\n\n');
    expect(actual.images).toEqual([]);
    expect(actual.title).toEqual('My Document');
    expect(actual.slug).toEqual('my-document');
  });

  it('passes extracted doc ID to fetchDoc', async () => {
    await gdocs2md('https://docs.google.com/document/d/abc123/edit');
    expect(__.fetchDoc).toHaveBeenCalledWith(expect.anything(), 'abc123');
  });
});
