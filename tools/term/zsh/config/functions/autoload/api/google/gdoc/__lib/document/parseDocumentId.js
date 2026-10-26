/**
 * Extract document ID and optional tab ID from a Google Docs URL or bare ID
 * @param {string} urlOrId - URL or document ID
 * @returns {object} { documentId, tabId }
 */
export function parseDocumentId(urlOrId) {
  const docMatch = urlOrId.match(/\/document\/d\/([^/?#]+)/);
  const documentId = docMatch ? docMatch[1] : urlOrId;

  const tabMatch = urlOrId.match(/[?&]tab=([^&#]+)/);
  const tabId = tabMatch ? tabMatch[1] : null;

  return { documentId, tabId };
}
