import { _ } from 'golgoth';
import { countGraphemes } from './countGraphemes.js';

const FACET_TYPE = 'app.bsky.richtext.facet';

/**
 * Describe parsed posts for --dry-run, without any network call
 * @param {object[]} posts - Posts returned by parsePostMarkdown
 * @returns {object[]} For each post: its `line`, `text`, `graphemes`, `bytes`, `links`, `hashtags` and `mentions`
 */
export function previewPosts(posts) {
  return _.map(posts, ({ text, line, facets }) => {
    const features = _.flatMap(facets, 'features');
    const pick = (type, key) => {
      return _.chain(features)
        .filter({ $type: `${FACET_TYPE}#${type}` })
        .map(key)
        .value();
    };

    return {
      line,
      text,
      graphemes: countGraphemes(text),
      bytes: Buffer.byteLength(text),
      links: pick('link', 'uri'),
      hashtags: pick('tag', 'tag'),
      mentions: pick('mention', 'handle'),
    };
  });
}
