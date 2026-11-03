import { _ } from 'golgoth';
import { firostError } from 'firost';

export let __;

/**
 * Find the unique position of a passage in the plain text of one paragraph
 * @param {object} doc - Document as returned by the Docs API
 * @param {string} passage - Plain text to find, ignoring formatting
 * @returns {{startIndex: number, endIndex: number}} Range expected by the Docs API, in UTF-16 units. Throws GDOC_PASSAGE_MISSING, GDOC_PASSAGE_REPEATED or GDOC_PASSAGE_MULTIPLE_PARAGRAPHS
 */
export function findPassage(doc, passage) {
  const paragraphs = __.listParagraphs(doc);
  const matches = _.flatMap(paragraphs, ({ startIndex, text }) =>
    __.findOffsets(text, passage).map((offset) => startIndex + offset),
  );

  if (matches.length > 1) {
    throw firostError(
      'GDOC_PASSAGE_REPEATED',
      `"${passage}" appears ${matches.length} times, use a longer passage`,
    );
  }
  if (matches.length === 1) {
    const [startIndex] = matches;
    return { startIndex, endIndex: startIndex + passage.length };
  }

  const joinedText = _.chain(paragraphs).map('text').join('').value();
  if (joinedText.includes(passage)) {
    throw firostError(
      'GDOC_PASSAGE_MULTIPLE_PARAGRAPHS',
      `"${passage}" spans several paragraphs, use gdoc-document-update instead`,
    );
  }
  throw firostError(
    'GDOC_PASSAGE_MISSING',
    `"${passage}" is not in the Document`,
  );
}

__ = {
  /**
   * List the paragraphs of the body with their plain text
   * @param {object} doc - Document as returned by the Docs API
   * @returns {Array<{startIndex: number, text: string}>} One entry per paragraph
   */
  listParagraphs(doc) {
    return _.chain(doc.body.content)
      .filter('paragraph')
      .map(({ startIndex, paragraph }) => ({
        startIndex,
        text: _.chain(paragraph.elements).map(__.elementText).join('').value(),
      }))
      .value();
  },
  /**
   * Plain text of a paragraph element. Non-text elements, like inline images,
   * take indexes but have no text, so they become placeholders to keep the
   * offsets aligned
   * @param {object} element - Paragraph element
   * @returns {string} Text of the element
   */
  elementText(element) {
    const { startIndex, endIndex, textRun } = element;
    return textRun?.content ?? '\0'.repeat(endIndex - startIndex);
  },
  /**
   * List every offset where the passage starts, overlapping ones included
   * @param {string} text - Text to search in
   * @param {string} passage - Text to find
   * @returns {number[]} Offsets in UTF-16 units
   */
  findOffsets(text, passage) {
    return _.chain(text.length)
      .range()
      .filter((offset) => text.startsWith(passage, offset))
      .value();
  },
};
