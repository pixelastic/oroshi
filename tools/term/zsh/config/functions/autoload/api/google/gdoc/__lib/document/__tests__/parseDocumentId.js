import { parseDocumentId } from '../parseDocumentId.js';

describe('parseDocumentId', () => {
  it.each([
    {
      title: 'URL with tab param returns both documentId and tabId',
      input:
        'https://docs.google.com/document/d/abc123xyz/edit?tab=t.slgbeb7sryb1',
      expected: { documentId: 'abc123xyz', tabId: 't.slgbeb7sryb1' },
    },
    {
      title: 'URL without tab param returns documentId and null tabId',
      input: 'https://docs.google.com/document/d/abc123xyz/edit',
      expected: { documentId: 'abc123xyz', tabId: null },
    },
    {
      title: 'URL with tab param and other query params returns correct tabId',
      input:
        'https://docs.google.com/document/d/abc123xyz/edit?foo=bar&tab=t.abc123&baz=qux',
      expected: { documentId: 'abc123xyz', tabId: 't.abc123' },
    },
    {
      title: 'bare document ID returns documentId and null tabId',
      input: 'abc123xyz',
      expected: { documentId: 'abc123xyz', tabId: null },
    },
    {
      title: 'URL with hash fragment and tab param returns correct tabId',
      input:
        'https://docs.google.com/document/d/abc123xyz/edit?tab=t.xyz789#heading=h.1',
      expected: { documentId: 'abc123xyz', tabId: 't.xyz789' },
    },
  ])('$title', ({ input, expected }) => {
    const actual = parseDocumentId(input);
    expect(actual).toEqual(expected);
  });
});
