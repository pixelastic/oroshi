import { _, pMap } from 'golgoth';
import { firostError } from 'firost';
import { resolveHandle } from './resolveHandle.js';

export let __;

const MENTION_TYPE = 'app.bsky.richtext.facet#mention';

/**
 * Replace the handle of each mention with the DID it resolves to
 * Each handle is resolved once. Without any mention, nothing is called.
 * Every handle that does not resolve is reported in one BLUESKY_UNKNOWN_HANDLE error.
 * @param {object[]} posts - Posts returned by parsePostMarkdown
 * @returns {Promise<object[]>} The posts, with mention features holding a `did`
 */
export async function resolveMentions(posts) {
  const handles = _.chain(posts)
    .flatMap('facets')
    .flatMap('features')
    .filter({ $type: MENTION_TYPE })
    .map('handle')
    .uniq()
    .value();

  const results = await pMap(handles, async (handle) => {
    return { handle, did: await __.resolveHandle(handle) };
  });

  // Report every unknown handle at once, before anything is sent
  const unknown = _.chain(results).reject('did').map('handle').value();
  if (!_.isEmpty(unknown)) {
    const list = _.map(unknown, (handle) => `@${handle}`);
    throw firostError(
      'BLUESKY_UNKNOWN_HANDLE',
      `Cannot resolve the handle: ${_.join(list, ', ')}`,
    );
  }

  const dids = _.chain(results).keyBy('handle').mapValues('did').value();
  return _.map(posts, (post) => {
    if (_.isEmpty(post.facets)) {
      return post;
    }
    const facets = _.map(post.facets, (facet) => {
      const features = _.map(facet.features, (feature) => {
        if (feature.$type !== MENTION_TYPE) {
          return feature;
        }
        return { $type: MENTION_TYPE, did: dids[feature.handle] };
      });
      return { ...facet, features };
    });
    return { ...post, facets };
  });
}

__ = {
  resolveHandle,
};
