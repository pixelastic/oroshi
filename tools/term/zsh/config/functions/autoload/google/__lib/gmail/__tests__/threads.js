import { _ } from 'golgoth';
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

  describe('list', () => {
    const auth = { fake: 'auth' };
    const message = (id, { from, internalDate, labelIds = [], ...rest }) => ({
      id,
      internalDate: String(internalDate),
      labelIds,
      snippet: `snippet ${id}`,
      payload: {
        headers: [
          { name: 'From', value: from },
          { name: 'Subject', value: rest.subject || `subject ${id}` },
          { name: 'Date', value: rest.date || `date ${id}` },
        ],
      },
    });
    const threads = {
      t1: {
        id: 't1',
        messages: [
          message('a1', {
            from: 'Alice <alice@example.com>',
            internalDate: 1000,
          }),
          message('a2', {
            from: 'Bob <bob@example.com>',
            internalDate: 2000,
            labelIds: ['UNREAD'],
          }),
          message('a3', {
            from: '"Alice" <alice@example.com>',
            internalDate: 3000,
          }),
        ],
      },
      t2: {
        id: 't2',
        messages: [
          message('b1', { from: 'Carol <carol@example.com>', internalDate: 1 }),
        ],
      },
      t3: {
        id: 't3',
        messages: [
          message('c1', {
            from: 'Dan <dan@example.com>',
            internalDate: 1,
            labelIds: ['UNREAD'],
          }),
        ],
      },
    };

    beforeEach(() => {
      vi.spyOn(__, 'fetchThreadIds').mockReturnValue([
        { id: 't1' },
        { id: 't2' },
        { id: 't3' },
      ]);
      vi.spyOn(__, 'fetchThreadMetadata').mockImplementation(
        (_auth, id) => threads[id],
      );
    });

    it('passes the query and the limit to the thread search', async () => {
      await gmailThreads.list(auth, { query: 'in:inbox', limit: 5 });

      expect(__.fetchThreadIds).toHaveBeenCalledWith(auth, {
        query: 'in:inbox',
        limit: 5,
      });
    });

    it('flags a thread with an unread message as unread', async () => {
      const actual = await gmailThreads.list(auth, { query: 'q', limit: 10 });

      expect(_.map(actual, 'unread')).toEqual([true, true, false]);
    });

    it('counts the messages of the thread', async () => {
      const actual = await gmailThreads.list(auth, { query: 'q', limit: 10 });

      expect(_.find(actual, { threadId: 't1' }).count).toEqual(3);
    });

    it('takes date, subject and snippet from the latest message', async () => {
      const actual = await gmailThreads.list(auth, { query: 'q', limit: 10 });

      expect(_.find(actual, { threadId: 't1' })).toMatchObject({
        date: 'date a3',
        subject: 'subject a3',
        snippet: 'snippet a3',
      });
    });

    it('deduplicates authors by display name, unread authors first', async () => {
      const actual = await gmailThreads.list(auth, { query: 'q', limit: 10 });

      expect(_.find(actual, { threadId: 't1' }).authors).toEqual([
        'Bob',
        'Alice',
      ]);
    });

    it('puts unread threads first, each group keeping its order', async () => {
      const actual = await gmailThreads.list(auth, { query: 'q', limit: 10 });

      expect(_.map(actual, 'threadId')).toEqual(['t1', 't3', 't2']);
    });

    it('gives back a thread without messages as an empty summary', async () => {
      vi.spyOn(__, 'fetchThreadIds').mockReturnValue([{ id: 't9' }]);
      vi.spyOn(__, 'fetchThreadMetadata').mockReturnValue({ id: 't9' });

      const actual = await gmailThreads.list(auth, { query: 'q', limit: 10 });

      expect(actual).toEqual([]);
    });

    it('returns no thread when the search finds none', async () => {
      vi.spyOn(__, 'fetchThreadIds').mockReturnValue([]);

      const actual = await gmailThreads.list(auth, { query: 'q', limit: 10 });

      expect(actual).toEqual([]);
    });
  });
});
