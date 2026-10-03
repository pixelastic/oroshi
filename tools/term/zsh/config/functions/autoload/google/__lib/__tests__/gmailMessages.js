import { __, gmailMessages } from '../gmailMessages.js';

describe('gmailMessages', () => {
  describe('list', () => {
    const auth = { fake: 'auth' };

    beforeEach(() => {
      vi.spyOn(__, 'fetchIds').mockReturnValue([{ id: 'a1' }, { id: 'b2' }]);
      vi.spyOn(__, 'fetchMessage').mockImplementation((_auth, id) => ({
        id,
        snippet: `snippet ${id}`,
        payload: {
          headers: [
            { name: 'From', value: `from-${id}@example.com` },
            { name: 'Subject', value: `subject ${id}` },
            { name: 'Date', value: 'Mon, 1 Jan 2026 10:00:00 +0000' },
          ],
        },
      }));
    });

    it.each([
      {
        title: 'passes the query untouched to the Gmail API',
        options: { query: 'from:bob  is:unread OR "exact phrase"', limit: 5 },
      },
      {
        title: 'applies the limit',
        options: { query: 'in:inbox', limit: 2 },
      },
    ])('$title', async ({ options }) => {
      await gmailMessages.list(auth, options);
      expect(__.fetchIds).toHaveBeenCalledWith(auth, options);
    });

    it('returns normalized messages', async () => {
      const actual = await gmailMessages.list(auth, {
        query: 'in:inbox',
        limit: 2,
      });
      expect(actual).toEqual([
        {
          id: 'a1',
          from: 'from-a1@example.com',
          subject: 'subject a1',
          date: 'Mon, 1 Jan 2026 10:00:00 +0000',
          snippet: 'snippet a1',
        },
        {
          id: 'b2',
          from: 'from-b2@example.com',
          subject: 'subject b2',
          date: 'Mon, 1 Jan 2026 10:00:00 +0000',
          snippet: 'snippet b2',
        },
      ]);
    });

    it('returns an empty list when nothing matches', async () => {
      vi.spyOn(__, 'fetchIds').mockReturnValue([]);
      const actual = await gmailMessages.list(auth, {
        query: 'in:inbox',
        limit: 2,
      });
      expect(actual).toEqual([]);
    });

    it('matches headers case-insensitively', async () => {
      vi.spyOn(__, 'fetchIds').mockReturnValue([{ id: 'c3' }]);
      vi.spyOn(__, 'fetchMessage').mockReturnValue({
        id: 'c3',
        snippet: 's',
        payload: { headers: [{ name: 'SUBJECT', value: 'Loud' }] },
      });
      const actual = await gmailMessages.list(auth, {
        query: 'in:inbox',
        limit: 1,
      });
      expect(actual).toEqual([
        { id: 'c3', from: '', subject: 'Loud', date: '', snippet: 's' },
      ]);
    });
  });
  describe('get', () => {
    const auth = { fake: 'auth' };
    const encode = (text) => Buffer.from(text, 'utf8').toString('base64url');
    const headers = [
      { name: 'From', value: 'alice@example.com' },
      { name: 'To', value: 'bob@example.com' },
      { name: 'Subject', value: 'Hello' },
      { name: 'Date', value: 'Mon, 1 Jan 2026 10:00:00 +0000' },
    ];
    const mockMessage = (payload) => {
      vi.spyOn(__, 'fetchFull').mockReturnValue({
        id: 'a1',
        snippet: 'snip',
        payload: { headers, ...payload },
      });
    };

    it('returns the headers and the id', async () => {
      mockMessage({ mimeType: 'text/plain', body: { data: encode('Hi') } });

      const actual = await gmailMessages.get(auth, 'a1');

      expect(actual).toEqual({
        id: 'a1',
        from: 'alice@example.com',
        to: 'bob@example.com',
        subject: 'Hello',
        date: 'Mon, 1 Jan 2026 10:00:00 +0000',
        snippet: 'snip',
        body: 'Hi',
      });
      expect(__.fetchFull).toHaveBeenCalledWith(auth, 'a1');
    });

    it('returns the text/plain part of a multipart mail', async () => {
      mockMessage({
        mimeType: 'multipart/alternative',
        parts: [
          { mimeType: 'text/html', body: { data: encode('<p>HTML body</p>') } },
          { mimeType: 'text/plain', body: { data: encode('Plain body') } },
        ],
      });

      const actual = await gmailMessages.get(auth, 'a1');

      expect(actual).toHaveProperty('body', 'Plain body');
    });

    it('finds the text/plain part in nested multiparts', async () => {
      mockMessage({
        mimeType: 'multipart/mixed',
        parts: [
          {
            mimeType: 'multipart/alternative',
            parts: [
              {
                mimeType: 'text/plain',
                body: { data: encode('Nested plain') },
              },
              {
                mimeType: 'text/html',
                body: { data: encode('<p>Nested</p>') },
              },
            ],
          },
          {
            mimeType: 'application/pdf',
            filename: 'a.pdf',
            body: { attachmentId: 'x' },
          },
        ],
      });

      const actual = await gmailMessages.get(auth, 'a1');

      expect(actual).toHaveProperty('body', 'Nested plain');
    });

    it('falls back to HTML converted to text when there is no plain part', async () => {
      mockMessage({
        mimeType: 'multipart/alternative',
        parts: [
          {
            mimeType: 'text/html',
            body: { data: encode('<p>Hello <b>world</b></p><p>Second</p>') },
          },
        ],
      });

      const actual = await gmailMessages.get(auth, 'a1');

      expect(actual).toHaveProperty('body', 'Hello world\n\nSecond');
    });

    it('decodes base64url content, including non-ASCII characters', async () => {
      const text = 'Café ?>> naïve — 日本語 🎉';
      mockMessage({ mimeType: 'text/plain', body: { data: encode(text) } });

      const actual = await gmailMessages.get(auth, 'a1');

      expect(actual).toHaveProperty('body', text);
    });

    it('returns an empty body when the mail has no text part', async () => {
      mockMessage({ mimeType: 'application/pdf', body: { attachmentId: 'x' } });

      const actual = await gmailMessages.get(auth, 'a1');

      expect(actual).toHaveProperty('body', '');
    });
  });
});
