import { __, validatePost } from '../validatePost.js';

describe('validatePost', () => {
  const post = (text, extra = {}) => ({
    text,
    facets: [],
    images: [],
    line: 1,
    ...extra,
  });
  const image = (name, extra = {}) => ({
    alt: 'Alt',
    path: `/drafts/${name}`,
    line: 3,
    ...extra,
  });
  // Size in bytes of the files that exist
  const sizes = {
    '/drafts/small.png': 500_000,
    '/drafts/small.jpg': 1_000_000,
    '/drafts/big.png': 1_000_001,
    '/drafts/anim.gif': 100,
  };

  beforeEach(() => {
    vi.spyOn(__, 'fileSize').mockImplementation((path) => sizes[path] ?? null);
  });

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
    {
      title: 'a post of four valid images, one at the limit, has no violation',
      posts: [
        post('Hello', {
          images: [
            image('small.png'),
            image('small.jpg'),
            image('small.png'),
            image('small.png'),
          ],
        }),
      ],
      expected: [],
    },
    {
      title: 'a fifth image is an error, at the line of that image',
      posts: [
        post('Hello', {
          images: [
            image('small.png'),
            image('small.png'),
            image('small.png'),
            image('small.png'),
            image('small.png', { line: 8 }),
          ],
        }),
      ],
      expected: [
        {
          code: 'too-many-images',
          level: 'error',
          line: 8,
          message: 'The post has 5 images, the limit is 4',
        },
      ],
    },
    {
      title: 'an image without alt text is an error, at its line',
      posts: [post('Hello', { images: [image('small.png', { alt: '' })] })],
      expected: [
        {
          code: 'missing-alt',
          level: 'error',
          line: 3,
          message: 'The image small.png has no alt text',
        },
      ],
    },
    {
      title: 'an alt text of only whitespace is missing',
      posts: [post('Hello', { images: [image('small.png', { alt: '  ' })] })],
      expected: [
        {
          code: 'missing-alt',
          level: 'error',
          line: 3,
          message: 'The image small.png has no alt text',
        },
      ],
    },
    {
      title: 'a missing file is an error',
      posts: [post('Hello', { images: [image('gone.png', { line: 5 })] })],
      expected: [
        {
          code: 'image-not-found',
          level: 'error',
          line: 5,
          message: 'The image gone.png does not exist',
        },
      ],
    },
    {
      title: 'an unsupported format is an error, even when the file exists',
      posts: [post('Hello', { images: [image('anim.gif')] })],
      expected: [
        {
          code: 'image-unsupported-format',
          level: 'error',
          line: 3,
          message: 'The image anim.gif is not a jpg or png',
        },
      ],
    },
    {
      title: 'an image over the limit is a warning, with its size',
      posts: [post('Hello', { images: [image('big.png')] })],
      expected: [
        {
          code: 'image-heavy',
          level: 'warning',
          line: 3,
          message:
            'The image big.png weighs 1000001 bytes, over the limit of 1000000: it will be compressed at publish time',
        },
      ],
    },
    {
      title: 'each image reports its own violations, after the text ones',
      posts: [
        post('', {
          images: [
            image('small.png', { alt: '', line: 2 }),
            image('gone.png', { line: 4 }),
          ],
        }),
      ],
      expected: [
        empty(1),
        {
          code: 'missing-alt',
          level: 'error',
          line: 2,
          message: 'The image small.png has no alt text',
        },
        {
          code: 'image-not-found',
          level: 'error',
          line: 4,
          message: 'The image gone.png does not exist',
        },
      ],
    },
  ])('$title', async ({ posts, expected }) => {
    const actual = await validatePost(posts);

    expect(actual).toEqual(expected);
  });
});
