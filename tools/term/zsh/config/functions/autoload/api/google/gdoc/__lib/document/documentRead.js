import { _ } from 'golgoth';
import { firostError } from 'firost';
import { callApi } from '../callApi.js';
import { convertToMarkdown } from './convertToMarkdown.js';
import { formatDocument } from './formatDocument.js';
import { parseDocumentId } from './parseDocumentId.js';

export let __;

/**
 * Read one tab of a Google Doc, converted to Markdown
 * @param {object} options - Id of the Document
 * @param {string} options.documentId - Document URL or ID. A ?tab= in the URL selects the tab, the first one otherwise. Throws GDOC_DOCUMENT_ID_MISSING if empty
 * @returns {Promise<object>} The Document, formatted
 */
export async function documentRead(options) {
  // Without a documentId, the endpoint would contain undefined
  if (!options.documentId) {
    throw firostError(
      'GDOC_DOCUMENT_ID_MISSING',
      'Pass the Document URL or ID',
    );
  }

  const { documentId, tabId } = parseDocumentId(options.documentId);
  const doc = await __.callApi(
    `documents/${documentId}?includeTabsContent=true`,
  );
  const tab = tabId ? __.findTab(doc.tabs, tabId) : doc.tabs[0];
  const flatDoc = __.formatTab(tab, doc);
  const { markdown, images } = convertToMarkdown(flatDoc);
  return __.formatDocument({
    documentId,
    title: flatDoc.title,
    markdown,
    images,
  });
}

__ = {
  /**
   * Find a tab by tabId in the Google Docs API tab tree.
   *
   * The API returns tabs as a tree — each tab can have nested childTabs:
   *   [
   *     { tabProperties: { tabId: "t.abc" }, childTabs: [
   *       { tabProperties: { tabId: "t.nested" }, childTabs: [] }
   *     ]},
   *     { tabProperties: { tabId: "t.xyz" }, childTabs: [] }
   *   ]
   *
   * We flatten the tree recursively into a single list, then find by tabId.
   *
   * Returns the matching tab object:
   *   {
   *     tabProperties: { tabId, title },
   *     documentTab: { body, inlineObjects, lists },
   *     childTabs: []
   *   }
   *
   * @param {object[]} tabs - Top-level tabs array from the API
   * @param {string} tabId - Tab ID to find (e.g. "t.slgbeb7sryb1")
   * @returns {object} Matching tab
   */
  findTab(tabs, tabId) {
    // Recursively collect all tabs (parent + children) into a flat array
    const flatten = (items) =>
      _.flatMap(items, (t) => [t, ...flatten(t.childTabs || [])]);
    const match = _.find(flatten(tabs), ['tabProperties.tabId', tabId]);
    if (!match) {
      throw firostError(
        'GDOC_TAB_NOT_FOUND',
        `Tab "${tabId}" not found in document`,
      );
    }
    return match;
  },

  /**
   * Flatten a tab into the flat doc shape { title, body, inlineObjects, lists }
   * that convertToMarkdown expects
   * @param {object} tab - Tab object from the API
   * @param {object} doc - Full document object (for title)
   * @returns {object} { title, body, inlineObjects, lists }
   */
  formatTab(tab, doc) {
    return {
      title: doc.title,
      body: tab.documentTab.body,
      inlineObjects: tab.documentTab.inlineObjects || {},
      lists: tab.documentTab.lists || {},
    };
  },

  callApi,
  formatDocument,
};
