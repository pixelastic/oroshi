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

    expect(actual).toEqual([{ line: 1, images: [], ...expected }]);
  });

  describe('threads', () => {
    it('keeps a line of three dashes in the text without the thread option', () => {
      const actual = parsePostMarkdown('First\n\n---\n\nSecond');

      expect(actual).toHaveLength(1);
      expect(actual).toHaveProperty('0.text', 'First\n\n---\n\nSecond');
    });

    it('keeps a line of three dashes that touches its text without the thread option', () => {
      const actual = parsePostMarkdown('One\n---\nTwo');

      expect(actual).toHaveLength(1);
      expect(actual).toHaveProperty('0.text', 'One\n\n---\n\nTwo');
    });

    it('splits the posts on each line of three dashes with the thread option', () => {
      const actual = parsePostMarkdown('One\n\n---\n\nTwo\n\n---\n\nThree', {
        thread: true,
      });

      expect(actual).toEqual([
        { text: 'One', facets: [], images: [], line: 1 },
        { text: 'Two', facets: [], images: [], line: 5 },
        { text: 'Three', facets: [], images: [], line: 9 },
      ]);
    });

    it('splits on a separator that touches its text', () => {
      const actual = parsePostMarkdown('One\n---\nTwo', { thread: true });

      expect(actual).toHaveProperty('0.text', 'One');
      expect(actual).toHaveProperty('1.text', 'Two');
    });

    it('gives each post its own facets, with offsets from its own text', () => {
      const actual = parsePostMarkdown('Hello\n\n---\n\nSee #news', {
        thread: true,
      });

      expect(actual).toHaveProperty('1.facets', [
        {
          index: { byteStart: 4, byteEnd: 9 },
          features: [{ $type: 'app.bsky.richtext.facet#tag', tag: 'news' }],
        },
      ]);
    });

    it('attaches an image to the post that holds it, with its source line', () => {
      const actual = parsePostMarkdown('One\n\n---\n\nTwo\n\n![Cat](cat.png)', {
        thread: true,
        directory: '/drafts',
      });

      expect(actual).toHaveProperty('0.images', []);
      expect(actual).toHaveProperty('1.images', [
        { alt: 'Cat', path: '/drafts/cat.png', line: 7 },
      ]);
    });

    it.each([
      {
        title: 'two separators in a row leave an empty post',
        input: 'One\n---\n---\nTwo',
        expected: [
          { text: 'One', line: 1 },
          { text: '', line: 3 },
          { text: 'Two', line: 4 },
        ],
      },
      {
        title: 'a leading separator leaves an empty first post',
        input: '---\nOne',
        expected: [
          { text: '', line: 1 },
          { text: 'One', line: 2 },
        ],
      },
      {
        title: 'a trailing separator leaves an empty last post',
        input: 'One\n---\n',
        expected: [
          { text: 'One', line: 1 },
          { text: '', line: 3 },
        ],
      },
    ])('$title', ({ input, expected }) => {
      const actual = parsePostMarkdown(input, { thread: true });

      expect(actual).toEqual(
        expected.map((post) => ({ facets: [], images: [], ...post })),
      );
    });
  });

  describe('images', () => {
    it.each([
      {
        title: 'an image leaves the text and keeps its alt and its path',
        input: 'Look\n\n![A red cat](cat.png)',
        options: { directory: '/drafts' },
        expected: {
          text: 'Look',
          images: [{ alt: 'A red cat', path: '/drafts/cat.png', line: 3 }],
        },
      },
      {
        title: 'a path is relative to the directory of the draft',
        input: '![Cat](./img/cat.png)',
        options: { directory: '/drafts/a' },
        expected: {
          text: '',
          images: [{ alt: 'Cat', path: '/drafts/a/img/cat.png', line: 1 }],
        },
      },
      {
        title: 'an absolute path stays as it is',
        input: '![Cat](/photos/cat.png)',
        options: { directory: '/drafts' },
        expected: {
          text: '',
          images: [{ alt: 'Cat', path: '/photos/cat.png', line: 1 }],
        },
      },
      {
        title: 'an image without alt has an empty alt',
        input: 'Hello\n\n![](cat.png)',
        options: { directory: '/drafts' },
        expected: {
          text: 'Hello',
          images: [{ alt: '', path: '/drafts/cat.png', line: 3 }],
        },
      },
      {
        title: 'images keep their order, inside a paragraph too',
        input: 'See ![One](a.png) and ![Two](b.jpg)',
        options: { directory: '/drafts' },
        expected: {
          text: 'See  and ',
          images: [
            { alt: 'One', path: '/drafts/a.png', line: 1 },
            { alt: 'Two', path: '/drafts/b.jpg', line: 1 },
          ],
        },
      },
      {
        title: 'the directory is the current directory by default',
        input: '![Cat](cat.png)',
        options: undefined,
        expected: {
          text: '',
          images: [{ alt: 'Cat', path: `${process.cwd()}/cat.png`, line: 1 }],
        },
      },
    ])('$title', ({ input, options, expected }) => {
      const actual = parsePostMarkdown(input, options);

      expect(actual).toEqual([{ line: 1, facets: [], ...expected }]);
    });
  });
});
