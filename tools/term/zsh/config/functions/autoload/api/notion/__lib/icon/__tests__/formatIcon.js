import { formatIcon } from '../formatIcon.js';

describe('formatIcon', () => {
  it.each([
    {
      title: 'emoji',
      input: { type: 'emoji', emoji: '🎲' },
      expected: '🎲',
    },
    {
      title: 'external image',
      input: {
        type: 'external',
        external: { url: 'https://example.com/a.png' },
      },
      expected: 'https://example.com/a.png',
    },
    {
      title: 'hosted file',
      input: {
        type: 'file',
        file: { url: 'https://s3.example.com/b.png', expiry_time: 'later' },
      },
      expected: 'https://s3.example.com/b.png',
    },
    { title: 'null icon', input: null, expected: '' },
    { title: 'missing icon', input: undefined, expected: '' },
  ])('returns the value of $title', ({ input, expected }) => {
    const actual = formatIcon(input);

    expect(actual).toEqual(expected);
  });
});
