import { _ } from 'golgoth';
import { callApi } from './callApi.js';

export let __;

/**
 * Ask the PDS for the DID of a handle
 * @param {string} handle - Handle of the account, without the @
 * @returns {Promise<string|null>} The DID, or null when the handle does not resolve
 */
export async function resolveHandle(handle) {
  try {
    const { did } = await __.callApi('com.atproto.identity.resolveHandle', {
      query: { handle },
    });
    return did;
  } catch (error) {
    // The PDS answers 400 for a handle that does not resolve
    const isUnknown =
      error.code === 'BLUESKY_REQUEST_FAILED' &&
      _.startsWith(error.message, '400');
    if (isUnknown) {
      return null;
    }
    throw error;
  }
}

__ = {
  callApi,
};
