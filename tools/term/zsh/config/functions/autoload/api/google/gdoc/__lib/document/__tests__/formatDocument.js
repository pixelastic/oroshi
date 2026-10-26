import { formatDocument } from '../formatDocument.js';

describe('formatDocument', () => {
  const input = {
    documentId: 'abc123',
    title: 'My Document',
    markdown: '# Hello\n',
    images: [
      { contentUri: 'https://img.test/1.png' },
      { contentUri: 'https://img.test/2.png' },
    ],
  };

  it('returns the id, title, url, markdown and image urls', () => {
    const actual = formatDocument(input);

    expect(actual).toEqual({
      id: 'abc123',
      title: 'My Document',
      url: 'https://docs.google.com/document/d/abc123/edit',
      markdown: '# Hello\n',
      images: ['https://img.test/1.png', 'https://img.test/2.png'],
    });
  });

  it('falls back to "untitled" without a title', () => {
    const actual = formatDocument({ ...input, title: undefined });

    expect(actual).toHaveProperty('title', 'untitled');
  });
});
