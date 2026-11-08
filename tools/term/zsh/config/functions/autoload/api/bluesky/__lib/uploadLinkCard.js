import { callApi } from './callApi.js';
import { MAX_IMAGE_BYTES } from './imageLimits.js';

export let __;

/**
 * Upload the image of a link card as a blob, and build its external embed
 * A card without image, or whose image cannot be fetched or is too large, is attached without thumbnail.
 * @param {object} card - Card returned by getLinkCard
 * @returns {Promise<object>} The `app.bsky.embed.external` embed
 */
export async function uploadLinkCard(card) {
  const { uri, title, description, imageUrl } = card;
  const thumb = imageUrl ? await __.uploadThumb(imageUrl) : null;

  return {
    $type: 'app.bsky.embed.external',
    external: { uri, title, description, ...(thumb ? { thumb } : {}) },
  };
}

__ = {
  fetch: globalThis.fetch,
  /**
   * Download an image and upload it as a blob
   * @param {string} imageUrl - Absolute URL of the image
   * @returns {Promise<object|null>} The blob, or null when the image cannot be used
   */
  async uploadThumb(imageUrl) {
    let body;
    let mimeType;
    try {
      const response = await __.fetch(imageUrl, { redirect: 'follow' });
      if (!response.ok) {
        return null;
      }
      mimeType = response.headers.get('content-type');
      body = Buffer.from(await response.arrayBuffer());
    } catch {
      return null;
    }

    if (body.length > MAX_IMAGE_BYTES) {
      return null;
    }

    const { blob } = await __.callApi('com.atproto.repo.uploadBlob', {
      method: 'POST',
      body,
      headers: { 'Content-Type': mimeType },
    });
    return blob;
  },
  callApi,
};
