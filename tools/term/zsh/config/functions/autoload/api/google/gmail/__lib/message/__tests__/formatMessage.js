import { formatMessage } from '../formatMessage.js';

describe('formatMessage', () => {
  /**
   * Build a Gmail mail, as returned with the metadata format
   * @param {string} id - Mail id
   * @param {object} fields - Fields of the mail
   * @returns {object} Gmail message resource
   */
  function mail(id, fields = {}) {
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

  it('gives the fields of a Message of one mail', () => {
    const actual = formatMessage({ id: 'conv1', messages: [mail('m1')] });

    expect(actual).toEqual({
      id: 'conv1',
      date: '2026-10-03T19:26:59.000Z',
      count: 1,
      authors: ['Alice Martin'],
      subject: 'Subject m1',
      snippet: 'Snippet m1',
      unread: false,
    });
  });

  it.each([
    {
      title: 'counts the mails and lists each author once',
      mails: [
        mail('m1', { from: 'Alice <a@example.com>', internalDate: '1' }),
        mail('m2', { from: 'Bob <b@example.com>', internalDate: '2' }),
        mail('m3', { from: 'Alice <a@example.com>', internalDate: '3' }),
      ],
      expected: { count: 3, authors: ['Alice', 'Bob'] },
    },
    {
      title: 'lists the authors of unread mails first',
      mails: [
        mail('m1', { from: 'Alice <a@example.com>', internalDate: '1' }),
        mail('m2', {
          from: 'Bob <b@example.com>',
          internalDate: '2',
          labelIds: ['INBOX', 'UNREAD'],
        }),
      ],
      expected: { authors: ['Bob', 'Alice'], unread: true },
    },
    {
      title: 'sorts the mails by their internal date',
      mails: [
        mail('m2', {
          date: 'Sat, 04 Oct 2026 10:00:00 +0200',
          internalDate: '2',
        }),
        mail('m1', {
          date: 'Fri, 03 Oct 2026 10:00:00 +0200',
          internalDate: '1',
        }),
      ],
      expected: { date: '2026-10-04T08:00:00.000Z' },
    },
    {
      title: 'shows the last mail received in the inbox, not the replies sent',
      mails: [
        mail('m1', { subject: 'Received', internalDate: '1' }),
        mail('m2', {
          subject: 'Sent',
          internalDate: '2',
          labelIds: ['SENT'],
        }),
      ],
      expected: { subject: 'Received', snippet: 'Snippet m1' },
    },
    {
      title: 'gives an empty date when the date is invalid',
      mails: [mail('m1', { date: 'not a date' })],
      expected: { date: '' },
    },
  ])('$title', ({ mails, expected }) => {
    const actual = formatMessage({ id: 'conv1', messages: mails });

    expect(actual).toMatchObject(expected);
  });
});
