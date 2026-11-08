import { resolve } from 'node:path';
import { _ } from 'golgoth';
import { fromMarkdown } from 'mdast-util-from-markdown';
import { gfmAutolinkLiteralFromMarkdown } from 'mdast-util-gfm-autolink-literal';
import { gfmStrikethroughFromMarkdown } from 'mdast-util-gfm-strikethrough';
import { gfmAutolinkLiteral } from 'micromark-extension-gfm-autolink-literal';
import { gfmStrikethrough } from 'micromark-extension-gfm-strikethrough';

export let __;

const FACET_TYPE = 'app.bsky.richtext.facet';
const BLOCK_NODE_TYPES = ['root', 'blockquote', 'list', 'listItem'];
const HANDLE_SEGMENT = '[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?';

/**
 * Convert a Markdown string into Bluesky posts
 * Links, hashtags and mentions become facets. Other formatting is removed and
 * its text kept. A mention facet carries the handle, not the DID.
 * @param {string} markdown - Markdown source of the post
 * @param {object} [options] - Options of the parser
 * @param {string} [options.directory] - Folder that the relative paths of the images start from
 * @param {boolean} [options.thread] - Split the Markdown into one post per line of three dashes. Without it, the dashes stay in the text
 * @returns {object[]} Posts, each with its `text`, its `facets` (UTF-8 byte
 * offsets of the text), its `images` (`alt`, absolute `path` and `line`, taken out of the text) and the `line` of the source where it starts
 */
export function parsePostMarkdown(markdown, options = {}) {
  const { directory = process.cwd(), thread = false } = options;
  const chunks = thread
    ? __.splitThread(markdown)
    : [{ markdown, lineOffset: 0 }];

  return _.map(chunks, ({ markdown: source, lineOffset }) => {
    return __.parsePost(source, directory, lineOffset);
  });
}

__ = {
  /**
   * Cut the Markdown of a Thread at each line of three dashes
   * The cut happens on the source, because Markdown reads a separator under a
   * line of text as a heading.
   * @param {string} markdown - Markdown source of the Thread
   * @returns {object[]} Chunks, each with its `markdown` and the `lineOffset` of its first line in the source
   */
  splitThread(markdown) {
    const chunks = [{ lines: [], lineOffset: 0 }];
    _.chain(markdown)
      .split('\n')
      .each((line, index) => {
        if (/^---\s*$/.test(line)) {
          chunks.push({ lines: [], lineOffset: index + 1 });
          return;
        }
        _.last(chunks).lines.push(line);
      })
      .value();

    return _.map(chunks, ({ lines, lineOffset }) => {
      return { markdown: _.join(lines, '\n'), lineOffset };
    });
  },
  /**
   * Convert the Markdown of one post
   * @param {string} markdown - Markdown source of the post
   * @param {string} directory - Folder that the relative paths of the images start from
   * @param {number} lineOffset - Number of lines that come before the post in the source
   * @returns {object} The post, with its `text`, `facets`, `images` and `line`
   */
  parsePost(markdown, directory, lineOffset) {
    const tree = fromMarkdown(markdown, {
      extensions: [gfmAutolinkLiteral(), gfmStrikethrough()],
      mdastExtensions: [
        gfmAutolinkLiteralFromMarkdown(),
        gfmStrikethroughFromMarkdown(),
      ],
    });
    __.restoreSetextDashes(tree, markdown);
    const pieces = __.collectPieces(tree);

    const facets = [];
    let byteStart = 0;
    _.each(pieces, ({ text, feature }) => {
      const byteEnd = byteStart + Buffer.byteLength(text);
      if (feature) {
        facets.push({ index: { byteStart, byteEnd }, features: [feature] });
      }
      byteStart = byteEnd;
    });

    return {
      text: _.chain(pieces).map('text').join('').value(),
      facets,
      images: _.map(__.collectImages(tree, directory), (image) => ({
        ...image,
        line: image.line + lineOffset,
      })),
      line: _.get(tree, 'children[0].position.start.line', 1) + lineOffset,
    };
  },
  /**
   * Put back the line of three dashes that Markdown swallowed as a heading underline
   * @param {object} node - mdast node, changed in place
   * @param {string} markdown - Markdown source that the node was parsed from
   */
  restoreSetextDashes(node, markdown) {
    if (node.type === 'heading') {
      const { start, end } = node.position;
      const source = markdown.slice(start.offset, end.offset);
      if (/\n---[ \t]*$/.test(source)) {
        node.children.push({ type: 'text', value: '\n\n---' });
      }
    }
    _.each(node.children, (child) => {
      __.restoreSetextDashes(child, markdown);
    });
  },
  /**
   * Find every image of a node, in the order of the source
   * @param {object} node - mdast node
   * @param {string} directory - Folder that the relative paths start from
   * @returns {object[]} Images, each with an `alt`, an absolute `path` and a `line`
   */
  collectImages(node, directory) {
    if (node.type === 'image') {
      return [
        {
          alt: node.alt ?? '',
          path: resolve(directory, node.url),
          line: node.position.start.line,
        },
      ];
    }
    return _.flatMap(node.children, (child) => {
      return __.collectImages(child, directory);
    });
  },
  /**
   * Flatten a node into the pieces of final text it holds
   * @param {object} node - mdast node
   * @returns {object[]} Pieces, each with a `text` and an optional `feature`
   */
  collectPieces(node) {
    if (node.type === 'text') {
      return __.splitText(node.value);
    }
    if (node.type === 'link') {
      const label = _.chain(node.children)
        .flatMap(__.collectPieces)
        .map('text')
        .join('')
        .value();
      return [
        {
          text: label,
          feature: { $type: `${FACET_TYPE}#link`, uri: node.url },
        },
      ];
    }
    if (node.type === 'break') {
      return [{ text: '\n' }];
    }
    if (node.children) {
      const separator = _.includes(BLOCK_NODE_TYPES, node.type) ? '\n\n' : '';
      return __.joinPieces(_.map(node.children, __.collectPieces), separator);
    }
    // A separator that is not a thread cut stays in the text
    if (node.type === 'thematicBreak') {
      return [{ text: '---' }];
    }
    // Code and HTML keep their text, but images have none
    return node.value ? [{ text: node.value }] : [];
  },
  /**
   * Chain groups of pieces, with a text separator between non-empty groups
   * @param {object[][]} groups - Groups of pieces
   * @param {string} separator - Text inserted between two groups
   * @returns {object[]} Pieces
   */
  joinPieces(groups, separator) {
    return _.chain(groups)
      .reject(_.isEmpty)
      .flatMap((group, index) => {
        return index === 0 ? group : [{ text: separator }, ...group];
      })
      .value();
  },
  /**
   * Cut a plain text into pieces, with a feature on each hashtag and mention
   * @param {string} value - Text without any Markdown formatting
   * @returns {object[]} Pieces, each with a `text` and an optional `feature`
   */
  splitText(value) {
    const pattern = new RegExp(
      `(?<=^|\\s)(?:#(?<hashtag>[^\\d\\s]\\S*)|@(?<handle>${HANDLE_SEGMENT}(?:\\.${HANDLE_SEGMENT})+))`,
      'gu',
    );
    const pieces = [];
    let cursor = 0;
    _.each([...value.matchAll(pattern)], (match) => {
      const { handle, hashtag } = match.groups;
      // Trailing punctuation belongs to the sentence, not to the hashtag
      const tag = _.replace(hashtag, /\p{P}+$/u, '');
      if (!handle && !tag) {
        return;
      }
      const text = handle ? `@${handle}` : `#${tag}`;
      const feature = handle
        ? { $type: `${FACET_TYPE}#mention`, handle }
        : { $type: `${FACET_TYPE}#tag`, tag };
      pieces.push({ text: value.slice(cursor, match.index) });
      pieces.push({ text, feature });
      cursor = match.index + text.length;
    });
    pieces.push({ text: value.slice(cursor) });

    return _.reject(pieces, { text: '' });
  },
};
