import { extractBodies } from '../extractBodies.js';

describe('extractBodies', () => {
  const encode = (text) => Buffer.from(text, 'utf8').toString('base64url');

  it.each([
    {
      title: 'a single text/plain part',
      input: { mimeType: 'text/plain', body: { data: encode('hello') } },
      expected: { text: 'hello', html: '' },
    },
    {
      title: 'a single text/html part',
      input: { mimeType: 'text/html', body: { data: encode('<p>hi</p>') } },
      expected: { text: '', html: '<p>hi</p>' },
    },
    {
      title: 'both parts, nested in multiparts, with non-ASCII characters',
      input: {
        mimeType: 'multipart/mixed',
        parts: [
          {
            mimeType: 'multipart/alternative',
            parts: [
              { mimeType: 'text/plain', body: { data: encode('héllo') } },
              { mimeType: 'text/html', body: { data: encode('<p>héllo</p>') } },
            ],
          },
          { mimeType: 'application/pdf', body: { attachmentId: 'a1' } },
        ],
      },
      expected: { text: 'héllo', html: '<p>héllo</p>' },
    },
    {
      title: 'no body',
      input: { mimeType: 'multipart/mixed', parts: [] },
      expected: { text: '', html: '' },
    },
    {
      title: 'no payload',
      input: undefined,
      expected: { text: '', html: '' },
    },
  ])('reads $title', ({ input, expected }) => {
    const actual = extractBodies(input);

    expect(actual).toEqual(expected);
  });
});
