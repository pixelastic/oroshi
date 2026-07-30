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
  ])('$title', ({ expected }) => {
    const actual = __.convertToMarkdown(richDoc);
    expect(actual).toContain(expected);
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
    const actual = __.convertToMarkdown(doc);
    expect(actual).toEqual(`${expected}Text\n`);
  });
});

describe('gdocs2md', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getAuth').mockReturnValue({ credentials: 'mock' });
    vi.spyOn(__, 'fetchDoc').mockReturnValue({
      body: {
        content: [paragraph([textRun('Hello\n')], 'HEADING_1')],
      },
      lists: {},
    });
  });

  it('returns markdown string', async () => {
    const actual = await gdocs2md('abc123');
    expect(actual).toEqual('# Hello\n');
  });

  it('passes extracted doc ID to fetchDoc', async () => {
    await gdocs2md('https://docs.google.com/document/d/abc123/edit');
    expect(__.fetchDoc).toHaveBeenCalledWith(expect.anything(), 'abc123');
  });
});
