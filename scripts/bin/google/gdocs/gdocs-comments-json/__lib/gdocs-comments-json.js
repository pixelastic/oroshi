import { fileURLToPath } from 'node:url';
import { _ } from 'golgoth';
import { google } from 'googleapis';
import { googleAuth } from '../../../__lib/googleAuth.js';

export let __;

/**
 * Fetch unresolved comments from a Google Doc as JSON
 * @param {string} urlOrId - Google Docs URL or document ID
 * @returns {object[]} Array of {anchor, comment} objects
 */
export async function gdocsCommentsJson(urlOrId) {
  const docId = __.extractDocId(urlOrId);
  const auth = await __.getAuth();
  const comments = await __.fetchComments(auth, docId);

  return _.chain(comments)
    .reject({ resolved: true })
    .sortBy('createdTime')
    .map((entry) => ({
      anchor: _.get(entry, 'quotedFileContent.value', ''),
      comment: entry.content,
    }))
    .value();
}

__ = {
  /**
   * Extract document ID from a Google Docs URL or bare ID
   * @param {string} urlOrId - URL or document ID
   * @returns {string} Document ID
   */
  extractDocId(urlOrId) {
    const match = urlOrId.match(/\/document\/d\/([^/]+)/);
    if (match) {
      return match[1];
    }
    return urlOrId;
  },

  /**
   * Get authenticated Google OAuth2 client
   * @returns {object} OAuth2Client
   */
  getAuth() {
    return googleAuth();
  },

  /**
   * Fetch comments from Drive API
   * @param {object} auth - Authenticated OAuth2 client
   * @param {string} docId - Document ID
   * @returns {object[]} Array of comment objects
   */
  async fetchComments(auth, docId) {
    const drive = google.drive({ version: 'v3', auth });
    let allComments = [];
    let pageToken;

    do {
      const response = await drive.comments.list({
        fileId: docId,
        fields:
          'nextPageToken,comments(content,resolved,quotedFileContent,createdTime)',
        pageToken,
      });
      allComments = [...allComments, ...(response.data.comments || [])];
      pageToken = response.data.nextPageToken;
    } while (pageToken);

    return allComments;
  },
};

// CLI entry
const currentFile = fileURLToPath(import.meta.url);
if (process.argv[1] === currentFile) {
  const input = process.argv[2];

  if (!input) {
    console.error('Usage: gdocs-comments-json <url-or-doc-id>');
    process.exit(1);
  }

  const result = await gdocsCommentsJson(input);
  console.log(JSON.stringify(result));
}
