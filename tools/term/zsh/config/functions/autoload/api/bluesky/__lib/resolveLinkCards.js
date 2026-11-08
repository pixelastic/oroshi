import { _, pMap } from 'golgoth';
import { getLinkCard } from './getLinkCard.js';

export let __;

const LINK_TYPE = 'app.bsky.richtext.facet#link';

/**
 * Fetch the link card of each post
 * A post has one embed at most: images win over the card, and only the first web link becomes a card. A page that cannot be fetched gives a warning, not an error.
 * @param {object[]} posts - Parsed posts, with their `facets` and `images`
 * @param {object} options - Options of the command
 * @param {boolean} [options.noEmbed] - Attach no card
 * @returns {Promise<object[]>} The posts, each with a `card` (or null) and its `warnings`
 */
export async function resolveLinkCards(posts, options) {
  return await pMap(posts, async (post) => {
    const { facets, images, line } = post;
    const uri = _.chain(facets)
      .flatMap('features')
      .filter({ $type: LINK_TYPE })
      .map('uri')
      .find((link) => /^https?:\/\//i.test(link))
      .value();

    if (options.noEmbed || !_.isEmpty(images) || !uri) {
      return { ...post, card: null, warnings: [] };
    }

    try {
      return { ...post, card: await __.getLinkCard(uri), warnings: [] };
    } catch (error) {
      return { ...post, card: null, warnings: [`${line} ${error.message}`] };
    }
  });
}

__ = {
  getLinkCard,
};
