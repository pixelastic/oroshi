import { _ } from 'golgoth';
import { firostError } from 'firost';

export let __;

/**
 * Fetch a page and read the data of its link card
 * The og:title, og:description and og:image tags win. The title of the page is the fallback title.
 * @param {string} url - URL of the page
 * @returns {Promise<{uri: string, title: string, description: string, imageUrl: string|null}>} The card, with an absolute `imageUrl` or null. Throws BLUESKY_LINK_CARD_FAILED when the page cannot be fetched
 */
export async function getLinkCard(url) {
  let html;
  try {
    const response = await __.fetch(url, { redirect: 'follow' });
    if (!response.ok) {
      throw new Error(`${response.status}`);
    }
    html = await response.text();
  } catch (error) {
    throw firostError(
      'BLUESKY_LINK_CARD_FAILED',
      `Cannot fetch ${url}: ${error.message}`,
    );
  }

  const tags = __.readMetaTags(html);
  const imageUrl = tags['og:image'];

  return {
    uri: url,
    title: tags['og:title'] || __.readPageTitle(html),
    description: tags['og:description'] || '',
    imageUrl: imageUrl ? new URL(imageUrl, url).href : null,
  };
}

__ = {
  fetch: globalThis.fetch,

  /**
   * Read the content of each <meta> tag, by its property or name
   * @param {string} html - HTML of the page
   * @returns {object} The decoded `content`, keyed by property or name. The first tag wins
   */
  readMetaTags(html) {
    const tags = {};
    _.each(html.match(/<meta\s[^>]*>/gi), (tag) => {
      const attributes = {};
      _.each(
        [...tag.matchAll(/([\w:-]+)\s*=\s*(?:"([^"]*)"|'([^']*)')/g)],
        ([, name, double, single]) => {
          attributes[name.toLowerCase()] = double ?? single;
        },
      );
      const key = attributes.property || attributes.name;
      if (key && _.has(attributes, 'content') && !_.has(tags, key)) {
        tags[key] = __.decodeEntities(attributes.content);
      }
    });
    return tags;
  },

  /**
   * Read the content of the <title> tag
   * @param {string} html - HTML of the page
   * @returns {string} The decoded and trimmed title, or an empty string
   */
  readPageTitle(html) {
    const [, title = ''] = html.match(/<title[^>]*>([\s\S]*?)<\/title>/i) ?? [];
    return __.decodeEntities(title).trim();
  },

  /**
   * Decode the common HTML entities of an attribute
   * @param {string} value - Text with entities
   * @returns {string} The decoded text
   */
  decodeEntities(value) {
    return _.chain(value)
      .replace(/&#(\d+);/g, (_match, code) => String.fromCodePoint(code))
      .replace(/&#x([\da-f]+);/gi, (_match, hex) =>
        String.fromCodePoint(Number.parseInt(hex, 16)),
      )
      .replace(/&quot;/g, '"')
      .replace(/&apos;/g, "'")
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&amp;/g, '&')
      .value();
  },
};
