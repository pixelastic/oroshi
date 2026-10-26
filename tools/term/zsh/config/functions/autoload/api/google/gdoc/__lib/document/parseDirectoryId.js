/**
 * Extract the folder ID from a Google Drive folder URL or bare ID
 * @param {string} [urlOrId] - URL or folder ID
 * @returns {string|undefined} The folder ID
 */
export function parseDirectoryId(urlOrId) {
  if (!urlOrId) {
    return undefined;
  }
  const match = urlOrId.match(/\/folders\/([^/?#]+)/);
  return match ? match[1] : urlOrId;
}
