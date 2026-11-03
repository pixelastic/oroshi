import { buildAppendRequests } from '../buildAppendRequests.js';

describe('buildAppendRequests', () => {
  // A paragraph of the converted Document, with its runs
  const paragraph = ({ startIndex, namedStyleType, bullet, runs }) => ({
    startIndex,
    paragraph: {
      paragraphStyle: { namedStyleType },
      ...(bullet && { bullet }),
      elements: runs.map(({ content, ...textStyle }) => ({
        textRun: { content, textStyle },
      })),
    },
  });

  // Converted Document: a heading, then a paragraph with a bold word
  const headingAndParagraph = {
    lists: {},
    body: {
      content: [
        { sectionBreak: {} },
        paragraph({
          startIndex: 1,
          namedStyleType: 'HEADING_1',
          runs: [{ content: 'Title\n' }],
        }),
        paragraph({
          startIndex: 7,
          namedStyleType: 'NORMAL_TEXT',
          runs: [
            { content: 'Hi ', bold: false },
            { content: 'bold', bold: true },
            { content: '\n', bold: false },
          ],
        }),
      ],
    },
  };

  // Converted Document: a list with a nested item, then a numbered list
  const lists = {
    lists: {
      'kix.list.2': {
        listProperties: { nestingLevels: [{ glyphSymbol: '•' }] },
      },
      'kix.list.3': {
        listProperties: {
          nestingLevels: [{ glyphSymbol: '•' }, { glyphSymbol: '–' }],
        },
      },
      'kix.list.4': {
        listProperties: { nestingLevels: [{ glyphType: 'DECIMAL' }] },
      },
    },
    body: {
      content: [
        paragraph({
          startIndex: 1,
          namedStyleType: 'NORMAL_TEXT',
          bullet: { listId: 'kix.list.2' },
          runs: [{ content: 'first\n' }],
        }),
        paragraph({
          startIndex: 7,
          namedStyleType: 'NORMAL_TEXT',
          bullet: { listId: 'kix.list.3', nestingLevel: 1 },
          runs: [{ content: 'nested\n' }],
        }),
        paragraph({
          startIndex: 14,
          namedStyleType: 'NORMAL_TEXT',
          bullet: { listId: 'kix.list.4' },
          runs: [{ content: 'one\n' }],
        }),
      ],
    },
  };

  const find = (requests, name) =>
    requests.filter((request) => request[name]).map((request) => request[name]);

  it('inserts after the existing text, before its last newline', () => {
    const actual = buildAppendRequests(headingAndParagraph, 20);

    expect(actual).toHaveProperty('0', {
      insertText: {
        location: { index: 19 },
        text: '\nTitle\nHi bold',
      },
    });
  });

  it('never deletes the existing content', () => {
    const actual = buildAppendRequests(headingAndParagraph, 20);

    expect(find(actual, 'deleteContentRange')).toEqual([]);
  });

  it('starts at the first paragraph when the Document is empty', () => {
    const actual = buildAppendRequests(headingAndParagraph, 2);

    expect(actual).toHaveProperty('0.insertText', {
      location: { index: 1 },
      text: 'Title\nHi bold',
    });
  });

  it('removes the bullets inherited from the last paragraph', () => {
    const actual = buildAppendRequests(headingAndParagraph, 20);

    expect(find(actual, 'deleteParagraphBullets')).toEqual([
      { range: { startIndex: 20, endIndex: 34 } },
    ]);
  });

  it('copies the style of each paragraph', () => {
    const actual = buildAppendRequests(headingAndParagraph, 20);

    expect(find(actual, 'updateParagraphStyle')).toEqual([
      {
        range: { startIndex: 20, endIndex: 26 },
        paragraphStyle: { namedStyleType: 'HEADING_1' },
        fields: 'namedStyleType',
      },
      {
        range: { startIndex: 26, endIndex: 34 },
        paragraphStyle: { namedStyleType: 'NORMAL_TEXT' },
        fields: 'namedStyleType',
      },
    ]);
  });

  it('copies the text style of each run, newlines included', () => {
    const actual = buildAppendRequests(headingAndParagraph, 20);

    const bolds = find(actual, 'updateTextStyle').map((request) => [
      request.range,
      request.textStyle.bold,
    ]);
    expect(bolds).toEqual([
      [{ startIndex: 20, endIndex: 26 }, undefined],
      [{ startIndex: 26, endIndex: 29 }, false],
      [{ startIndex: 29, endIndex: 33 }, true],
      [{ startIndex: 33, endIndex: 34 }, false],
    ]);
  });

  it('resets the style fields a run does not set', () => {
    const actual = buildAppendRequests(headingAndParagraph, 20);

    const [request] = find(actual, 'updateTextStyle');
    expect(request).toHaveProperty(
      'fields',
      'bold,italic,link,weightedFontFamily',
    );
  });

  it('copies the link and the font of a run', () => {
    const doc = {
      lists: {},
      body: {
        content: [
          paragraph({
            startIndex: 1,
            namedStyleType: 'NORMAL_TEXT',
            runs: [
              {
                content: 'a link\n',
                link: { url: 'https://example.com' },
                weightedFontFamily: { fontFamily: 'Roboto', weight: 400 },
              },
            ],
          }),
        ],
      },
    };

    const [actual] = find(buildAppendRequests(doc, 2), 'updateTextStyle');

    expect(actual).toHaveProperty('textStyle', {
      link: { url: 'https://example.com' },
      weightedFontFamily: { fontFamily: 'Roboto', weight: 400 },
    });
  });

  it('indents a nested item with tabs, which the bullet creation consumes', () => {
    const actual = buildAppendRequests(lists, 2);

    expect(actual).toHaveProperty('0.insertText.text', 'first\n\tnested\none');
  });

  it('creates bullets from the end, so earlier ranges stay valid', () => {
    const actual = buildAppendRequests(lists, 2);

    expect(find(actual, 'createParagraphBullets')).toEqual([
      {
        range: { startIndex: 15, endIndex: 19 },
        bulletPreset: 'NUMBERED_DECIMAL_ALPHA_ROMAN',
      },
      {
        range: { startIndex: 1, endIndex: 15 },
        bulletPreset: 'BULLET_DISC_CIRCLE_SQUARE',
      },
    ]);
  });

  it('ignores the elements that are not paragraphs', () => {
    const doc = {
      lists: {},
      body: {
        content: [
          { sectionBreak: {} },
          { table: {} },
          ...headingAndParagraph.body.content,
        ],
      },
    };

    const actual = buildAppendRequests(doc, 20);

    expect(actual).toHaveProperty('0.insertText.text', '\nTitle\nHi bold');
  });
});
