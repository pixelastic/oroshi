import { formatThread } from '../formatThread.js';

describe('formatThread', () => {
  /**
   * Build a Gmail message, as returned by the API
   * @param {string} id - Message id
   * @param {object} fields - Fields of the message
   * @returns {object} Gmail message resource
   */
  function message(id, fields = {}) {
    const {
      from = 'Alice Martin <alice@example.com>',
      subject = `Subject ${id}`,
      date = 'Fri, 03 Oct 2026 21:26:59 +0200',
      internalDate = '1',
      labelIds = ['INBOX'],
      snippet = `Snippet ${id}`,
    } = fields;
    return {
      id,
      internalDate,
      labelIds,
      snippet,
      payload: {
        headers: [
          { name: 'from', value: from },
          { name: 'SUBJECT', value: subject },
          { name: 'Date', value: date },
        ],
      },
    };
  }

  describe('envelope', () => {
    it('gives the threadId, whose Message ids differ from it', () => {
      const actual = formatThread({ id: 't1', messages: [message('m1')] });

      expect(actual).toHaveProperty('threadId', 't1');
      expect(actual).toHaveProperty('messages[0].messageId', 'm1');
    });

    it('gives the Messages oldest first, each with its own messageId', () => {
      const actual = formatThread({
        id: 't1',
        messages: [
          message('m3', { internalDate: '3' }),
          message('m1', { internalDate: '1' }),
          message('m2', { internalDate: '2' }),
        ],
      });

      expect(actual.messages.map((item) => item.messageId)).toEqual([
        'm1',
        'm2',
        'm3',
      ]);
    });

    it.each([
      {
        title: 'is unread when one Message is unread',
        labelIds: [['INBOX'], ['INBOX', 'UNREAD'], ['INBOX']],
        expected: true,
      },
      {
        title: 'is read when no Message is unread',
        labelIds: [['INBOX'], ['SENT']],
        expected: false,
      },
    ])('$title', ({ labelIds, expected }) => {
      const messages = labelIds.map((labels, index) =>
        message(`m${index}`, { labelIds: labels, internalDate: `${index}` }),
      );

      const actual = formatThread({ id: 't1', messages });

      expect(actual).toHaveProperty('unread', expected);
    });

    it.each([
      {
        title: 'takes the subject of the last Message received in the inbox',
        messages: [
          message('m1', { subject: 'Received', internalDate: '1' }),
          message('m2', {
            subject: 'Sent',
            internalDate: '2',
            labelIds: ['SENT'],
          }),
        ],
        expected: 'Received',
      },
      {
        title:
          'takes the subject of the last Message when none is in the inbox',
        messages: [
          message('m1', {
            subject: 'First',
            internalDate: '1',
            labelIds: ['SENT'],
          }),
          message('m2', {
            subject: 'Last',
            internalDate: '2',
            labelIds: ['SENT'],
          }),
        ],
        expected: 'Last',
      },
    ])('$title', ({ messages, expected }) => {
      const actual = formatThread({ id: 't1', messages });

      expect(actual).toHaveProperty('subject', expected);
    });
  });

  describe('list fields', () => {
    it('gives the fields of a Thread of one Message', () => {
      const actual = formatThread({ id: 't1', messages: [message('m1')] });

      expect(actual).toMatchObject({
        date: '2026-10-03T19:26:59.000Z',
        count: 1,
        authors: ['Alice Martin'],
        snippet: 'Snippet m1',
      });
    });

    it.each([
      {
        title: 'counts the Messages and lists each author once',
        messages: [
          message('m1', { from: 'Alice <a@example.com>', internalDate: '1' }),
          message('m2', { from: 'Bob <b@example.com>', internalDate: '2' }),
          message('m3', { from: 'Alice <a@example.com>', internalDate: '3' }),
        ],
        expected: { count: 3, authors: ['Alice', 'Bob'] },
      },
      {
        title: 'lists the authors of unread Messages first',
        messages: [
          message('m1', { from: 'Alice <a@example.com>', internalDate: '1' }),
          message('m2', {
            from: 'Bob <b@example.com>',
            internalDate: '2',
            labelIds: ['INBOX', 'UNREAD'],
          }),
        ],
        expected: { authors: ['Bob', 'Alice'] },
      },
      {
        title: 'dates the Thread with its last Message',
        messages: [
          message('m2', {
            date: 'Sat, 04 Oct 2026 10:00:00 +0200',
            internalDate: '2',
          }),
          message('m1', {
            date: 'Fri, 03 Oct 2026 10:00:00 +0200',
            internalDate: '1',
          }),
        ],
        expected: { date: '2026-10-04T08:00:00.000Z' },
      },
      {
        title: 'takes the snippet of the Message that gives the subject',
        messages: [
          message('m1', { internalDate: '1' }),
          message('m2', { internalDate: '2', labelIds: ['SENT'] }),
        ],
        expected: { snippet: 'Snippet m1' },
      },
      {
        title: 'gives an empty date when the date is invalid',
        messages: [message('m1', { date: 'not a date' })],
        expected: { date: '' },
      },
    ])('$title', ({ messages, expected }) => {
      const actual = formatThread({ id: 't1', messages });

      expect(actual).toMatchObject(expected);
    });
  });
});
