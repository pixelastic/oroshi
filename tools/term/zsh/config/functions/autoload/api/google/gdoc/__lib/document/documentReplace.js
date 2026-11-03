import { _ } from 'golgoth';
import { firostError, read } from 'firost';
import { callApi } from '../callApi.js';
import { findPassage } from './findPassage.js';
import { formatDocument } from './formatDocument.js';
import { parseDocumentId } from './parseDocumentId.js';
import { parseInlineMarkdown } from './parseInlineMarkdown.js';

export let __;

/**
 * Swap one passage of a Google Doc for another, keeping the rest of the
 * Document and its comments. An empty new passage removes the old one
 * @param {object} options - Document and passages
 * @param {string} options.documentId - Document URL or ID. Throws GDOC_DOCUMENT_ID_MISSING if empty
 * @param {string} [options.old] - Passage to find, as plain text of one paragraph. Throws GDOC_PASSAGE_OLD_MISSING if empty
 * @param {string} [options.oldFile] - Path to a text file. Wins over old
 * @param {string} [options.new] - Passage to put instead, as inline Markdown
 * @param {string} [options.newFile] - Path to a Markdown file. Wins over new
 * @returns {Promise<object>} The updated Document, formatted
 */
export async function documentReplace(options) {
  // Without a documentId, the endpoint would contain undefined
  if (!options.documentId) {
    throw firostError(
      'GDOC_DOCUMENT_ID_MISSING',
      'Pass the Document URL or ID',
    );
  }
  const oldPassage = options.oldFile
    ? await __.read(options.oldFile)
    : options.old;
  // An empty passage would match everywhere
  if (!oldPassage) {
    throw firostError(
      'GDOC_PASSAGE_OLD_MISSING',
      'Pass the passage to find with --old or --old-file',
    );
  }
  const newPassage = options.newFile
    ? await __.read(options.newFile)
    : (options.new ?? '');

  const { documentId } = parseDocumentId(options.documentId);
  const doc = await __.callApi(`documents/${documentId}`);
  const { startIndex, endIndex } = __.findPassage(doc, oldPassage);
  const { text, ranges } = __.parseInlineMarkdown(newPassage);

  await __.callApi(`documents/${documentId}:batchUpdate`, {
    method: 'POST',
    body: {
      requests: [
        { deleteContentRange: { range: { startIndex, endIndex } } },
        ...(text
          ? [{ insertText: { location: { index: startIndex }, text } }]
          : []),
        ..._.map(ranges, (range) => __.styleRequest(range, startIndex)),
      ],
    },
  });

  return __.formatDocument({ documentId, title: doc.title });
}

__ = {
  /**
   * Text styles applied for each style of an inline Markdown range
   */
  textStyles: {
    bold: () => ({ textStyle: { bold: true }, fields: 'bold' }),
    italic: () => ({ textStyle: { italic: true }, fields: 'italic' }),
    code: () => ({
      textStyle: { weightedFontFamily: { fontFamily: 'Courier New' } },
      fields: 'weightedFontFamily',
    }),
    link: ({ url }) => ({ textStyle: { link: { url } }, fields: 'link' }),
  },
  /**
   * Build the request that styles one range of the inserted text
   * @param {object} range - Range of the inline Markdown, relative to the inserted text
   * @param {number} offset - Index of the document where the text is inserted
   * @returns {object} An updateTextStyle request
   */
  styleRequest(range, offset) {
    const { textStyle, fields } = __.textStyles[range.style](range);
    return {
      updateTextStyle: {
        range: {
          startIndex: offset + range.startIndex,
          endIndex: offset + range.endIndex,
        },
        textStyle,
        fields,
      },
    };
  },
  callApi,
  findPassage,
  formatDocument,
  parseInlineMarkdown,
  read,
};
