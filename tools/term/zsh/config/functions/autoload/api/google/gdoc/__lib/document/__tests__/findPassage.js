import { findPassage } from '../findPassage.js';

/**
 * Build a Document JSON from paragraphs, each made of text runs
 * @param {string[][]} paragraphs - Text runs of each paragraph
 * @returns {object} Document as returned by the Docs API
 */
function buildDocument(paragraphs) {
  // Index 0 is taken by the section break
  let index = 1;
  const content = paragraphs.map((runs) => {
    const paragraphStart = index;
    const elements = runs.map((text) => {
      const startIndex = index;
      index += text.length;
      return { startIndex, endIndex: index, textRun: { content: text } };
    });
    return {
      startIndex: paragraphStart,
      endIndex: index,
      paragraph: { elements },
    };
  });
  return { body: { content: [{ endIndex: 1, sectionBreak: {} }, ...content] } };
}

describe('findPassage', () => {
  it.each([
    {
      title: 'returns the range of a unique passage',
      paragraphs: [['Hello world\n'], ['Second paragraph\n']],
      passage: 'Second',
      expected: { startIndex: 13, endIndex: 19 },
    },
    {
      title: 'matches a passage that crosses several styled runs',
      paragraphs: [['Say ', 'hello ', 'world', ' now\n']],
      passage: 'hello world',
      expected: { startIndex: 5, endIndex: 16 },
    },
    {
      title:
        'counts indexes in UTF-16 units, so accents and emojis stay aligned',
      paragraphs: [['Café 😄 ', 'target\n']],
      passage: 'target',
      expected: { startIndex: 9, endIndex: 15 },
    },
  ])('$title', ({ paragraphs, passage, expected }) => {
    const actual = findPassage(buildDocument(paragraphs), passage);

    expect(actual).toEqual(expected);
  });

  it.each([
    {
      title: 'missing',
      paragraphs: [['Hello world\n']],
      passage: 'absent',
      code: 'GDOC_PASSAGE_MISSING',
    },
    {
      title: 'repeated',
      paragraphs: [['Hello world\n'], ['Hello again\n']],
      passage: 'Hello',
      code: 'GDOC_PASSAGE_REPEATED',
    },
    {
      title: 'repeated in the same paragraph',
      paragraphs: [['one two one\n']],
      passage: 'one',
      code: 'GDOC_PASSAGE_REPEATED',
    },
    {
      title: 'spanning two paragraphs',
      paragraphs: [['First paragraph\n'], ['Second paragraph\n']],
      passage: 'paragraph\nSecond',
      code: 'GDOC_PASSAGE_MULTIPLE_PARAGRAPHS',
    },
  ])(
    'throws $code when the passage is $title',
    ({ paragraphs, passage, code }) => {
      let actual = null;
      try {
        findPassage(buildDocument(paragraphs), passage);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', code);
    },
  );

  it('tells to use update when the passage spans two paragraphs', () => {
    const doc = buildDocument([['First\n'], ['Second\n']]);

    let actual = null;
    try {
      findPassage(doc, 'First\nSecond');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty(
      'message',
      '"First\nSecond" spans several paragraphs, use gdoc-document-update instead',
    );
  });
});
