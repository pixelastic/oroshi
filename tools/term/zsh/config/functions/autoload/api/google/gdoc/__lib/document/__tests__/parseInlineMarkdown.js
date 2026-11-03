import { parseInlineMarkdown } from '../parseInlineMarkdown.js';

describe('parseInlineMarkdown', () => {
  it.each([
    {
      title: 'returns plain text unchanged, with no range',
      input: 'Hello world',
      expected: { text: 'Hello world', ranges: [] },
    },
    {
      title: 'reads bold',
      input: 'a **bold** word',
      expected: {
        text: 'a bold word',
        ranges: [{ startIndex: 2, endIndex: 6, style: 'bold' }],
      },
    },
    {
      title: 'reads italic',
      input: 'an *italic* word',
      expected: {
        text: 'an italic word',
        ranges: [{ startIndex: 3, endIndex: 9, style: 'italic' }],
      },
    },
    {
      title: 'reads inline code',
      input: 'run `ls -la` now',
      expected: {
        text: 'run ls -la now',
        ranges: [{ startIndex: 4, endIndex: 10, style: 'code' }],
      },
    },
    {
      title: 'reads a link',
      input: 'see [the docs](https://example.com/a) here',
      expected: {
        text: 'see the docs here',
        ranges: [
          {
            startIndex: 4,
            endIndex: 12,
            style: 'link',
            url: 'https://example.com/a',
          },
        ],
      },
    },
    {
      title: 'reads bold and italic nested',
      input: '**bold and *both***',
      expected: {
        text: 'bold and both',
        ranges: [
          { startIndex: 9, endIndex: 13, style: 'italic' },
          { startIndex: 0, endIndex: 13, style: 'bold' },
        ],
      },
    },
    {
      title: 'gives ranges that match the stripped text',
      input: 'x **one** y *two* z `three`',
      expected: {
        text: 'x one y two z three',
        ranges: [
          { startIndex: 2, endIndex: 5, style: 'bold' },
          { startIndex: 8, endIndex: 11, style: 'italic' },
          { startIndex: 14, endIndex: 19, style: 'code' },
        ],
      },
    },
    {
      title: 'leaves a heading marker as plain text',
      input: '# Title with **bold**',
      expected: {
        text: '# Title with bold',
        ranges: [{ startIndex: 13, endIndex: 17, style: 'bold' }],
      },
    },
    {
      title: 'counts ranges in UTF-16 units',
      input: '😀 **é😀**',
      expected: {
        text: '😀 é😀',
        ranges: [{ startIndex: 3, endIndex: 6, style: 'bold' }],
      },
    },
  ])('$title', ({ input, expected }) => {
    const actual = parseInlineMarkdown(input);
    expect(actual).toEqual(expected);
  });

  it.each([
    { title: 'bold', input: '**bold**' },
    { title: 'italic', input: '*italic*' },
  ])('does not read $title markers inside inline code', ({ input }) => {
    const actual = parseInlineMarkdown(`\`${input}\``);
    expect(actual).toEqual({
      text: input,
      ranges: [{ startIndex: 0, endIndex: input.length, style: 'code' }],
    });
  });
});
