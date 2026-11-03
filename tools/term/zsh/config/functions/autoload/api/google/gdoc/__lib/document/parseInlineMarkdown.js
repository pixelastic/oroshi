import { _ } from 'golgoth';

export let __;

/**
 * Turn inline Markdown into plain text and style ranges. Block syntax, like
 * headings or lists, stays as plain text
 * @param {string} markdown - Inline Markdown: bold, italic, links, inline code
 * @returns {{text: string, ranges: Array<{startIndex: number, endIndex: number, style: string, url?: string}>}} Plain text, and styled ranges in UTF-16 units. Inner ranges come before the ranges that wrap them
 */
export function parseInlineMarkdown(markdown) {
  if (markdown === '') {
    return { text: '', ranges: [] };
  }

  const token = __.matchToken(markdown) ?? __.plainToken(markdown);
  const rest = parseInlineMarkdown(markdown.slice(token.length));
  return {
    text: token.text + rest.text,
    ranges: [
      ...token.ranges,
      ...rest.ranges.map((range) => ({
        ...range,
        startIndex: range.startIndex + token.text.length,
        endIndex: range.endIndex + token.text.length,
      })),
    ],
  };
}

__ = {
  /**
   * Syntaxes tried at the start of the Markdown, in order. Content of inline
   * code is never parsed
   */
  syntaxes: [
    { style: 'code', regex: /^`([^`]+)`/, isParsed: false },
    { style: 'link', regex: /^\[([^\]]+)\]\(([^)\s]+)\)/, isParsed: true },
    {
      style: 'bold',
      regex: /^\*\*(?!\s)(.+?)(?<!\s)\*\*(?!\*)/,
      isParsed: true,
    },
    { style: 'italic', regex: /^\*(?!\s)(.+?)(?<!\s)\*(?!\*)/, isParsed: true },
  ],
  /**
   * Read the styled span that starts the Markdown, if any
   * @param {string} markdown - Markdown to read from
   * @returns {{length: number, text: string, ranges: object[]}|undefined} Consumed length, plain text and ranges of the span
   */
  matchToken(markdown) {
    return _.chain(__.syntaxes)
      .map(({ style, regex, isParsed }) => {
        const match = markdown.match(regex);
        if (!match) {
          return null;
        }
        const [source, content, url] = match;
        const inner = isParsed
          ? parseInlineMarkdown(content)
          : { text: content, ranges: [] };
        const range = {
          startIndex: 0,
          endIndex: inner.text.length,
          style,
          ...(url && { url }),
        };
        return {
          length: source.length,
          text: inner.text,
          ranges: [...inner.ranges, range],
        };
      })
      .compact()
      .first()
      .value();
  },
  /**
   * Read the plain text that starts the Markdown, up to the next character
   * that could start a styled span
   * @param {string} markdown - Markdown to read from
   * @returns {{length: number, text: string, ranges: object[]}} Consumed length, plain text and no range
   */
  plainToken(markdown) {
    // The first character is always taken, as it failed to start a styled span
    const nextSpecial = markdown.slice(1).search(/[`[*]/);
    const length = nextSpecial === -1 ? markdown.length : nextSpecial + 1;
    return { length, text: markdown.slice(0, length), ranges: [] };
  },
};
