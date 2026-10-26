import { _ } from 'golgoth';

/**
 * Format one Document, to give every command the same output
 * @param {object} input - The Document, as read from the API
 * @param {string} input.documentId - Document ID
 * @param {string} [input.title] - Title of the Document
 * @param {string} input.markdown - Markdown of the tab
 * @param {object[]} input.images - Images of the tab, as { contentUri }
 * @returns {object} The Document as { id, title, url, markdown, images }
 */
export function formatDocument(input) {
  const { documentId, title, markdown, images } = input;
  return {
    id: documentId,
    title: title || 'untitled',
    url: `https://docs.google.com/document/d/${documentId}/edit`,
    markdown,
    images: _.map(images, 'contentUri'),
  };
}
