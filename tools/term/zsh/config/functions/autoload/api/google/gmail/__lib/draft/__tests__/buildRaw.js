import { simpleParser } from 'mailparser';
import { buildRaw } from '../buildRaw.js';

describe('buildRaw', () => {
  const parse = async (raw) =>
    await simpleParser(Buffer.from(raw, 'base64url'));

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

  it('encodes a non-ASCII subject', async () => {
    const raw = await buildRaw({
      to: 'a@example.com',
      subject: 'AI First × Algolia',
      body: 'hi',
    });

    const actual = await parse(raw);

    expect(actual).toHaveProperty('subject', 'AI First × Algolia');
    expect(Buffer.from(raw, 'base64url').toString('utf8')).not.toContain('×');
  });
});
