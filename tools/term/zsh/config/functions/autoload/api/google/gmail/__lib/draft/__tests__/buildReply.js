import { buildReply } from '../buildReply.js';

describe('buildReply', () => {
  const mail = {
    from: 'Alice <alice@example.com>',
    replyTo: '',
    subject: 'Hello',
    messageId: '<m2@example.com>',
    references: '',
  };

  it.each([
    { title: 'adds the prefix', subject: 'Hello', expected: 'Re: Hello' },
    { title: 'keeps the prefix', subject: 'Re: Hello', expected: 'Re: Hello' },
  ])('$title to the subject', ({ subject, expected }) => {
    const actual = buildReply({ ...mail, subject });

    expect(actual).toHaveProperty('subject', expected);
  });

  it.each([
    {
      title: 'replies to From without a Reply-To',
      replyTo: '',
      expected: 'Alice <alice@example.com>',
    },
    {
      title: 'replies to Reply-To when present',
      replyTo: 'support@example.com',
      expected: 'support@example.com',
    },
  ])('$title', ({ replyTo, expected }) => {
    const actual = buildReply({ ...mail, replyTo });

    expect(actual).toHaveProperty('to', expected);
  });

  it('sets In-Reply-To to the last Message-ID', () => {
    const actual = buildReply(mail);

    expect(actual).toHaveProperty('inReplyTo', '<m2@example.com>');
  });

  it.each([
    {
      title: 'appends the Message-ID to the previous references',
      references: '<m0@example.com> <m1@example.com>',
      expected: '<m0@example.com> <m1@example.com> <m2@example.com>',
    },
    {
      title: 'uses the Message-ID alone without references',
      references: '',
      expected: '<m2@example.com>',
    },
  ])('$title', ({ references, expected }) => {
    const actual = buildReply({ ...mail, references });

    expect(actual).toHaveProperty('references', expected);
  });
});
