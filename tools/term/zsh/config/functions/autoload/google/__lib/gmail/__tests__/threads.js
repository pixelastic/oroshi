import { __, gmailThreads } from '../threads.js';

describe('gmailThreads', () => {
  describe('get', () => {
    const auth = { fake: 'auth' };
    const encode = (text) => Buffer.from(text, 'utf8').toString('base64url');
    const headers = (id) => [
      { name: 'From', value: `from-${id}@example.com` },
      { name: 'To', value: 'bob@example.com' },
      { name: 'Subject', value: 'Hello' },
      { name: 'Date', value: 'Mon, 1 Jan 2026 10:00:00 +0000' },
    ];

    beforeEach(() => {
      vi.spyOn(__, 'fetchThread').mockReturnValue({
        id: 't1',
        messages: [
          {
            id: 'b2',
            internalDate: '2000',
            snippet: 'snippet b2',
            payload: {
              headers: headers('b2'),
              mimeType: 'text/html',
              body: { data: encode('<p>Only <b>HTML</b></p>') },
            },
          },
          {
            id: 'a1',
            internalDate: '1000',
            snippet: 'snippet a1',
            payload: {
              headers: headers('a1'),
              mimeType: 'multipart/mixed',
              parts: [
                { mimeType: 'text/plain', body: { data: encode('First') } },
                {
                  partId: '1',
                  mimeType: 'application/pdf',
                  filename: 'a.pdf',
                  body: { attachmentId: 'x', size: 12 },
                },
              ],
            },
          },
        ],
      });
    });

    it('returns every message of the thread, oldest first', async () => {
      const actual = await gmailThreads.get(auth, 't1');

      expect(actual.map((message) => message.id)).toEqual(['a1', 'b2']);
      expect(__.fetchThread).toHaveBeenCalledWith(auth, 't1');
    });

    it('keeps the id, body and attachments of each message', async () => {
      const actual = await gmailThreads.get(auth, 't1');

      expect(actual).toEqual([
        {
          id: 'a1',
          from: 'from-a1@example.com',
          to: 'bob@example.com',
          subject: 'Hello',
          date: 'Mon, 1 Jan 2026 10:00:00 +0000',
          snippet: 'snippet a1',
          body: 'First',
          attachments: [
            {
              partId: '1',
              filename: 'a.pdf',
              mimeType: 'application/pdf',
              size: 12,
            },
          ],
        },
        {
          id: 'b2',
          from: 'from-b2@example.com',
          to: 'bob@example.com',
          subject: 'Hello',
          date: 'Mon, 1 Jan 2026 10:00:00 +0000',
          snippet: 'snippet b2',
          body: 'Only HTML',
          attachments: [],
        },
      ]);
    });

    it('decodes the body of each message like a single read does', async () => {
      const actual = await gmailThreads.get(auth, 't1');

      expect(actual.map((message) => message.body)).toEqual([
        'First',
        'Only HTML',
      ]);
    });

    it('returns an empty array for a thread without messages', async () => {
      vi.spyOn(__, 'fetchThread').mockReturnValue({ id: 't1' });

      const actual = await gmailThreads.get(auth, 't1');

      expect(actual).toEqual([]);
    });
  });
});
