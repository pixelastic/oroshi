import { simpleParser } from 'mailparser';
import { buildRaw } from '../buildRaw.js';

describe('buildRaw', () => {
  const parse = async (raw) => await simpleParser(raw);

  it('sets the recipient, the subject and a plain-text body', async () => {
    const raw = await buildRaw({
      to: 'a@example.com',
      subject: 'Hello',
      body: 'hi there',
    });

    const actual = await parse(raw);

    expect(actual).toHaveProperty('to.text', 'a@example.com');
    expect(actual).toHaveProperty('subject', 'Hello');
    expect(actual.text.trim()).toEqual('hi there');
    expect(actual).toHaveProperty('html', false);
  });

  it('sends the HTML of the body next to its text', async () => {
    const raw = await buildRaw({
      to: 'a@example.com',
      subject: 'Hello',
      body: '- one',
      html: '<ul>\n<li>one</li>\n</ul>',
    });

    const actual = await parse(raw);

    expect(actual.text.trim()).toEqual('- one');
    expect(actual).toHaveProperty(
      'html',
      '<div dir="ltr"><ul>\n<li>one</li>\n</ul></div>',
    );
  });

  it('sets the threading headers', async () => {
    const raw = await buildRaw({
      to: 'a@example.com',
      subject: 'Re: Hello',
      body: 'hi',
      inReplyTo: '<m2@example.com>',
      references: '<m1@example.com> <m2@example.com>',
    });

    const actual = await parse(raw);

    expect(actual).toHaveProperty('inReplyTo', '<m2@example.com>');
    expect(actual).toHaveProperty('references', [
      '<m1@example.com>',
      '<m2@example.com>',
    ]);
  });

  it('encodes a non-ASCII subject', async () => {
    const raw = await buildRaw({
      to: 'a@example.com',
      subject: 'AI First × Algolia',
      body: 'hi',
    });

    const actual = await parse(raw);

    expect(actual).toHaveProperty('subject', 'AI First × Algolia');
    expect(raw.toString('utf8')).not.toContain('×');
  });

  it('sets the sender and the copies', async () => {
    const raw = await buildRaw({
      from: 'me@example.com',
      to: 'a@example.com',
      cc: 'b@example.com, Carol <c@example.com>',
      subject: 'Hello',
      body: 'hi',
    });

    const actual = await parse(raw);

    expect(actual).toHaveProperty('from.text', 'me@example.com');
    expect(actual).toHaveProperty('cc.value.length', 2);
    expect(actual).toHaveProperty('cc.value.1.address', 'c@example.com');
  });

  it('returns the mail as a Buffer', async () => {
    const actual = await buildRaw({
      to: 'a@example.com',
      subject: 'Hello',
      body: 'hi',
    });

    expect(Buffer.isBuffer(actual)).toEqual(true);
  });

  it('attaches the files', async () => {
    const raw = await buildRaw({
      to: 'a@example.com',
      subject: 'Hello',
      body: 'hi',
      attachments: [
        {
          filename: 'report.pdf',
          contentType: 'application/pdf',
          content: Buffer.from('PDF-BYTES'),
        },
      ],
    });

    const actual = await parse(raw);

    expect(actual.text.trim()).toEqual('hi');
    expect(actual).toHaveProperty('attachments.length', 1);
    expect(actual).toHaveProperty('attachments.0.filename', 'report.pdf');
    expect(actual).toHaveProperty(
      'attachments.0.contentType',
      'application/pdf',
    );
    expect(actual.attachments[0].content.toString()).toEqual('PDF-BYTES');
  });

  it('keeps the cid of an inline attachment', async () => {
    const raw = await buildRaw({
      to: 'a@example.com',
      subject: 'Hello',
      body: 'hi',
      html: '<img src="cid:logo">',
      attachments: [
        {
          filename: 'logo.png',
          contentType: 'image/png',
          content: Buffer.from('PNG'),
          cid: 'logo',
        },
      ],
    });

    const actual = await parse(raw);

    expect(actual).toHaveProperty('attachments.0.cid', 'logo');
  });

  it('adds no attachment by default', async () => {
    const raw = await buildRaw({
      to: 'a@example.com',
      subject: 'Hello',
      body: 'hi',
    });

    const actual = await parse(raw);

    expect(actual).toHaveProperty('attachments', []);
  });

  it('sets no Cc header when cc is empty', async () => {
    const raw = await buildRaw({
      to: 'a@example.com',
      cc: '',
      subject: 'Hello',
      body: 'hi',
    });

    const actual = await parse(raw);

    expect(actual.cc).toBeUndefined();
  });
});
