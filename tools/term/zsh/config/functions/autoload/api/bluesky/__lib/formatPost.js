import { _ } from 'golgoth';

/**
 * Format a created Post, to give every command the same output
 * @param {object} response - The record, as returned by the PDS
 * @returns {{uri: string, url: string}} The AT URI and the bsky.app URL
 */
export function formatPost(response) {
  const { uri } = response;
  const [did, , rkey] = _.chain(uri).replace('at://', '').split('/').value();

  return { uri, url: `https://bsky.app/profile/${did}/post/${rkey}` };
}
