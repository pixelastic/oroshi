import { buildReply } from '../buildReply.js';

describe('buildReply', () => {
  const aliases = ['me@example.com', 'work@example.com'];
  const mail = {
    from: 'Alice <alice@example.com>',
    replyTo: '',
    to: 'me@example.com',
    cc: '',
    subject: 'Hello',
    messageId: '<m2@example.com>',
    references: '',
  };

  it.each([
    { title: 'adds the prefix', subject: 'Hello', expected: 'Re: Hello' },
    { title: 'keeps the prefix', subject: 'Re: Hello', expected: 'Re: Hello' },
  ])('$title to the subject', ({ subject, expected }) => {
    const actual = buildReply({ ...mail, subject }, aliases);

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
    const actual = buildReply({ ...mail, replyTo }, aliases);

    expect(actual).toHaveProperty('to', expected);
  });

  it('sets In-Reply-To to the last Message-ID', () => {
    const actual = buildReply(mail, aliases);

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
    const actual = buildReply({ ...mail, references }, aliases);

    expect(actual).toHaveProperty('references', expected);
  });

  it.each([
    {
      title: 'puts the other recipients of the last Mail in Cc',
      mail: {
        to: 'me@example.com, Carol <carol@example.com>',
        cc: 'dave@example.com',
      },
      expectedTo: 'Alice <alice@example.com>',
      expectedCc: 'Carol <carol@example.com>, dave@example.com',
    },
    {
      title: 'removes every alias from To and Cc',
      mail: {
        from: 'work@example.com',
        replyTo: 'Me <me@example.com>',
        to: 'work@example.com, carol@example.com',
        cc: 'me@example.com',
      },
      expectedTo: 'carol@example.com',
      expectedCc: '',
    },
    {
      title: 'does not duplicate a To recipient in Cc',
      mail: {
        to: 'me@example.com',
        cc: 'Alice <alice@example.com>, carol@example.com',
      },
      expectedTo: 'Alice <alice@example.com>',
      expectedCc: 'carol@example.com',
    },
    {
      title:
        'replies to the recipients of the last Mail when the user wrote it',
      mail: {
        from: 'Me <me@example.com>',
        to: 'Alice <alice@example.com>, work@example.com',
        cc: 'carol@example.com',
      },
      expectedTo: 'Alice <alice@example.com>',
      expectedCc: 'carol@example.com',
    },
    {
      title: 'compares addresses case-insensitively',
      mail: {
        from: 'ALICE@example.com',
        to: 'Me <ME@Example.com>, alice@EXAMPLE.com, carol@example.com',
      },
      expectedTo: 'ALICE@example.com',
      expectedCc: 'carol@example.com',
    },
    {
      title: 'keeps an empty Cc empty',
      mail: {},
      expectedTo: 'Alice <alice@example.com>',
      expectedCc: '',
    },
  ])('$title', ({ mail: overrides, expectedTo, expectedCc }) => {
    const actual = buildReply({ ...mail, ...overrides }, aliases);

    expect(actual).toHaveProperty('to', expectedTo);
    expect(actual).toHaveProperty('cc', expectedCc);
  });

  describe('from', () => {
    it.each([
      {
        title: 'picks the alias that received the last Mail',
        to: 'Carol <carol@example.com>',
        cc: 'Work <WORK@example.com>',
        expected: 'work@example.com',
      },
      {
        title: 'picks the alias found in To',
        to: 'carol@example.com, work@example.com',
        cc: '',
        expected: 'work@example.com',
      },
      {
        title: 'picks the first alias of the recipients, To before Cc',
        to: 'work@example.com',
        cc: 'me@example.com',
        expected: 'work@example.com',
      },
      {
        title: 'falls back to the first alias when no alias received it',
        to: 'carol@example.com',
        cc: 'dave@example.com',
        expected: 'me@example.com',
      },
    ])('$title', ({ to, cc, expected }) => {
      const actual = buildReply({ ...mail, to, cc }, aliases);

      expect(actual).toHaveProperty('from', expected);
    });
  });
});
