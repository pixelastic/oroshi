import { _ } from 'golgoth';
import { callApi } from '../callApi.js';

export let __;

/**
 * Map the id of each Draft Message to the id of its Draft. The Gmail API
 * gives a Draft for a Message id only through the list of all the Drafts
 * @param {string} [pageToken] - Token of the page of the list to start from
 * @returns {Promise<object>} The Draft ids, keyed by the id of their Message
 */
export async function getDraftIds(pageToken) {
  const response = await __.callApi('drafts', {
    query: _.pickBy({ pageToken }),
  });
  const draftIds = _.chain(response.drafts)
    .map((draft) => [draft.message.id, draft.id])
    .fromPairs()
    .value();

  if (!response.nextPageToken) {
    return draftIds;
  }

  return { ...draftIds, ...(await getDraftIds(response.nextPageToken)) };
}

__ = {
  callApi,
};
