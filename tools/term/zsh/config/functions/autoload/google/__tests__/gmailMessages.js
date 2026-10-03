import { __, gmailMessages } from '../__lib/gmailMessages.js';

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
});
