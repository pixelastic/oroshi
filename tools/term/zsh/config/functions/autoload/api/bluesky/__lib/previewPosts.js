import { _, pMap } from 'golgoth';
import { countGraphemes } from './countGraphemes.js';
import { fileSize } from './fileSize.js';

export let __;

const FACET_TYPE = 'app.bsky.richtext.facet';

/**
 * Describe parsed posts for --dry-run, without any upload
 * @param {object[]} posts - Posts returned by resolveLinkCards, whose mention features hold a `did`
 * @returns {Promise<object[]>} For each post: its `line`, `text`, `graphemes`, `bytes`, `links`, `hashtags`, `mentions` (the DIDs), `images` (`alt`, `path` and `size` in bytes of the original file), `card` (`title`, `description` and `imageUrl`, or null) and `warnings`
 */
export async function previewPosts(posts) {
  return await pMap(posts, async (post) => {
    const { text, line, facets, images, card = null, warnings = [] } = post;
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
      mentions: pick('mention', 'did'),
      images: await pMap(images, async ({ alt, path }) => {
        return { alt, path, size: await __.fileSize(path) };
      }),
      card: card && _.pick(card, ['title', 'description', 'imageUrl']),
      warnings,
    };
  });
}

__ = {
  fileSize,
};
