import { formatMail } from '../formatMail.js';

describe('formatMail', () => {
  const encode = (text) => Buffer.from(text, 'utf8').toString('base64url');
  const headers = [
    { name: 'From', value: 'alice@example.com' },
    { name: 'To', value: 'bob@example.com' },
    { name: 'Subject', value: 'Hello' },
    { name: 'Date', value: 'Mon, 1 Jan 2026 10:00:00 +0000' },
  ];
  /**
   * Build a Gmail mail, as returned with the full format
   * @param {object} payload - Payload of the mail, merged with its headers
   * @returns {object} Gmail message resource
   */
  function mail(payload) {
    return { id: 'a1', snippet: 'snip', payload: { headers, ...payload } };
  }

  it('returns the headers and the id', () => {
    const actual = formatMail(
      mail({ mimeType: 'text/plain', body: { data: encode('Hi') } }),
    );

    expect(actual).toEqual({
      id: 'a1',
      from: 'alice@example.com',
      to: 'bob@example.com',
      subject: 'Hello',
      date: 'Mon, 1 Jan 2026 10:00:00 +0000',
      snippet: 'snip',
      body: 'Hi',
      attachments: [],
    });
  });

  it.each([
    {
      title: 'returns the text/plain part of a multipart mail',
      payload: {
        mimeType: 'multipart/alternative',
        parts: [
          { mimeType: 'text/html', body: { data: encode('<p>HTML body</p>') } },
          { mimeType: 'text/plain', body: { data: encode('Plain body') } },
        ],
      },
      expected: 'Plain body',
    },
    {
      title: 'finds the text/plain part in nested multiparts',
      payload: {
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
      },
      expected: 'Nested plain',
    },
    {
      title: 'converts an HTML-only mail to plain text',
      payload: {
        mimeType: 'multipart/alternative',
        parts: [
          {
            mimeType: 'text/html',
            body: { data: encode('<p>Hello <b>world</b></p><p>Second</p>') },
          },
        ],
      },
      expected: 'Hello world\n\nSecond',
    },
    {
      title: 'decodes base64url content, including non-ASCII characters',
      payload: {
        mimeType: 'text/plain',
        body: { data: encode('Café ?>> naïve — 日本語 🎉') },
      },
      expected: 'Café ?>> naïve — 日本語 🎉',
    },
    {
      title: 'returns an empty body when the mail has no text part',
      payload: { mimeType: 'application/pdf', body: { attachmentId: 'x' } },
      expected: '',
    },
  ])('$title', ({ payload, expected }) => {
    const actual = formatMail(mail(payload));

    expect(actual).toHaveProperty('body', expected);
  });

  it('lists the attachments, including nested ones, without their Gmail id', () => {
    const actual = formatMail(
      mail({
        mimeType: 'multipart/mixed',
        parts: [
          {
            mimeType: 'multipart/alternative',
            parts: [
              {
                mimeType: 'application/pdf',
                filename: 'report.pdf',
                partId: '1.2',
                body: { attachmentId: 'att-1', size: 42 },
              },
            ],
          },
          { mimeType: 'text/plain', filename: '', body: { size: 3 } },
        ],
      }),
    );

    expect(actual).toHaveProperty('attachments', [
      {
        partId: '1.2',
        filename: 'report.pdf',
        mimeType: 'application/pdf',
        size: 42,
      },
    ]);
  });
});
