import { parsePostMarkdown } from '../parsePostMarkdown.js';

describe('parsePostMarkdown', () => {
  const link = (uri) => ({ $type: 'app.bsky.richtext.facet#link', uri });
  const tag = (value) => ({ $type: 'app.bsky.richtext.facet#tag', tag: value });
  const mention = (handle) => ({
    $type: 'app.bsky.richtext.facet#mention',
    handle,
  });
  const facet = (byteStart, byteEnd, feature) => ({
    index: { byteStart, byteEnd },
    features: [feature],
  });

  it.each([
    {
      title: 'a labeled link keeps its label and covers it',
      input: 'Read [my post](https://example.com/a) now',
      expected: {
        text: 'Read my post now',
        facets: [facet(5, 12, link('https://example.com/a'))],
      },
    },
    {
      title: 'a bare URL is covered',
      input: 'See https://example.com/a now',
      expected: {
        text: 'See https://example.com/a now',
        facets: [facet(4, 25, link('https://example.com/a'))],
      },
    },
    {
      title: 'a hashtag is covered without its trailing punctuation',
      input: 'Hello #bluesky, friends',
      expected: {
        text: 'Hello #bluesky, friends',
        facets: [facet(6, 14, tag('bluesky'))],
      },
    },
    {
      title: 'a mention keeps its handle and is covered without punctuation',
      input: 'Thanks @alice.bsky.social!',
      expected: {
        text: 'Thanks @alice.bsky.social!',
        facets: [facet(7, 25, mention('alice.bsky.social'))],
      },
    },
    {
      title: 'bold, italic and strikethrough markers disappear',
      input: '**bold** and *italic* and ~~struck~~',
      expected: { text: 'bold and italic and struck', facets: [] },
    },
    {
      title: 'emoji and accents before a link shift the byte offsets',
      input: 'Café 🎉 [link](https://example.com) end',
      expected: {
        text: 'Café 🎉 link end',
        facets: [facet(11, 15, link('https://example.com'))],
      },
    },
    {
      title: 'several links, hashtags and mentions are all covered',
      input:
        '🎉 Café [docs](https://example.com/docs) by @bob.example.com #news #café, see https://example.org/x.',
      expected: {
        text: '🎉 Café docs by @bob.example.com #news #café, see https://example.org/x.',
        facets: [
          facet(11, 15, link('https://example.com/docs')),
          facet(19, 35, mention('bob.example.com')),
          facet(36, 41, tag('news')),
          facet(42, 48, tag('café')),
          facet(54, 75, link('https://example.org/x')),
        ],
      },
    },
    {
      title: 'paragraphs stay separated by a blank line',
      input: 'First\n\nSecond',
      expected: { text: 'First\n\nSecond', facets: [] },
    },
    {
      title: 'an empty string is one empty post',
      input: '',
      expected: { text: '', facets: [] },
    },
    {
      title: 'the line is the source line where the post starts',
      input: '\n\nHello',
      expected: { text: 'Hello', facets: [], line: 3 },
    },
  ])('$title', ({ input, expected }) => {
    const actual = parsePostMarkdown(input);

    expect(actual).toEqual([{ line: 1, ...expected }]);
  });
});
