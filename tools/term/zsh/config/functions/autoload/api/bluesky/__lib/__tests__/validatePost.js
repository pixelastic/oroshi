import { validatePost } from '../validatePost.js';

describe('validatePost', () => {
  const post = (text, extra = {}) => ({ text, facets: [], line: 1, ...extra });

  const empty = (line) => ({
    code: 'empty',
    level: 'error',
    line,
    message: 'The post has no text',
  });
  const tooLongGraphemes = (count, line) => ({
    code: 'too-long-graphemes',
    level: 'error',
    line,
    message: `The post has ${count} graphemes, the limit is 300`,
  });
  const tooLongBytes = (count, line) => ({
    code: 'too-long-bytes',
    level: 'error',
    line,
    message: `The post has ${count} bytes, the limit is 3000`,
  });

  it.each([
    {
      title: 'a post of 300 graphemes has no violation',
      posts: [post('a'.repeat(300))],
      expected: [],
    },
    {
      title: 'a clean draft has no violation',
      posts: [post('Hello world')],
      expected: [],
    },
    {
      title: 'a post of 301 graphemes is too long, at its line',
      posts: [post('a'.repeat(301), { line: 4 })],
      expected: [tooLongGraphemes(301, 4)],
    },
    {
      title: 'a post over 3000 bytes is too long even under 300 graphemes',
      // A family emoji is one grapheme made of 25 bytes
      posts: [post('👨‍👩‍👧‍👦'.repeat(125))],
      expected: [tooLongBytes(3125, 1)],
    },
    {
      title: 'an empty post is an error',
      posts: [post('')],
      expected: [empty(1)],
    },
    {
      title: 'a post of only whitespace is empty',
      posts: [post(' \n ')],
      expected: [empty(1)],
    },
    {
      title: 'only the label of a link counts in the length',
      posts: [
        post('See my post', {
          facets: [
            {
              index: { byteStart: 4, byteEnd: 11 },
              features: [
                {
                  $type: 'app.bsky.richtext.facet#link',
                  uri: `https://example.com/${'a'.repeat(400)}`,
                },
              ],
            },
          ],
        }),
      ],
      expected: [],
    },
    {
      title: 'each post reports its own violations',
      posts: [
        post('ok'),
        post('', { line: 7 }),
        post('b'.repeat(301), { line: 9 }),
      ],
      expected: [empty(7), tooLongGraphemes(301, 9)],
    },
  ])('$title', ({ posts, expected }) => {
    const actual = validatePost(posts);

    expect(actual).toEqual(expected);
  });
});
