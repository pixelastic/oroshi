import { __, draftCreate } from '../draftCreate.js';

describe('draftCreate', () => {
  const options = { to: 'a@example.com', subject: 'Hello', body: 'hi' };

  beforeEach(() => {
    vi.spyOn(__, 'buildRaw').mockReturnValue('RAW');
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'd1',
      message: { id: 'm1', threadId: 't1' },
    });
    vi.spyOn(__, 'getAliases').mockReturnValue([
      'me@example.com',
      'work@example.com',
    ]);
  });

  it('does not read the aliases without --messageId', async () => {
    await draftCreate(options);

    expect(__.getAliases).not.toHaveBeenCalled();
  });

  it('builds the raw mail from the options', async () => {
    await draftCreate(options);

    expect(__.buildRaw).toHaveBeenCalledWith(options);
  });

  describe('with --bodyFile', () => {
    const fileOptions = { to: 'a@example.com', subject: 'Hello' };

    beforeEach(() => {
      vi.spyOn(__, 'read').mockReturnValue('- one');
      vi.spyOn(__, 'renderBody').mockReturnValue({
        text: '- one',
        html: '<ul>HTML</ul>',
      });
    });

    it('renders the content of the file', async () => {
      await draftCreate({ ...fileOptions, bodyFile: '/tmp/body.md' });

      expect(__.read).toHaveBeenCalledWith('/tmp/body.md');
      expect(__.renderBody).toHaveBeenCalledWith({
        body: undefined,
        file: { path: '/tmp/body.md', content: '- one' },
      });
    });

    it('builds the raw mail with the text and the HTML', async () => {
      await draftCreate({ ...fileOptions, bodyFile: '/tmp/body.md' });

      expect(__.buildRaw).toHaveBeenCalledWith(
        expect.objectContaining({ body: '- one', html: '<ul>HTML</ul>' }),
      );
    });

    it('does not read a file without --bodyFile', async () => {
      await draftCreate(options);

      expect(__.read).not.toHaveBeenCalled();
    });
  });

  it('posts the raw mail to drafts.create', async () => {
    await draftCreate(options);

    expect(__.callApi).toHaveBeenCalledWith('drafts', {
      method: 'POST',
      body: { message: { raw: 'RAW' } },
    });
  });

  it('returns the draft id, the thread id and the Gmail URL', async () => {
    const actual = await draftCreate(options);

    expect(actual).toEqual({
      draftId: 'd1',
      threadId: 't1',
      url: 'https://mail.google.com/mail/u/0/#drafts?compose=m1',
    });
  });

  describe('with --messageId', () => {
    const replyOptions = { messageId: 't1', body: 'hi' };
    const thread = {
      messages: [
        {
          internalDate: '2000',
          payload: {
            headers: [
              { name: 'From', value: 'Bob <bob@example.com>' },
              {
                name: 'To',
                value: 'Carol <carol@example.com>, work@example.com',
              },
              { name: 'Cc', value: 'dave@example.com, me@example.com' },
              { name: 'Date', value: 'Mon, 26 Oct 2026 10:05:00 +0100' },
              { name: 'Subject', value: 'Re: Hello' },
              { name: 'Message-ID', value: '<m2@example.com>' },
              { name: 'References', value: '<m1@example.com>' },
            ],
          },
        },
        {
          internalDate: '1000',
          payload: {
            headers: [
              { name: 'From', value: 'Alice <alice@example.com>' },
              { name: 'Subject', value: 'Hello' },
              { name: 'Message-ID', value: '<m1@example.com>' },
            ],
          },
        },
      ],
    };

    beforeEach(() => {
      vi.spyOn(__, 'extractBodies').mockReturnValue({
        text: 'orig',
        html: '<p>orig</p>',
      });
      vi.spyOn(__, 'buildQuote').mockReturnValue({
        html: 'QUOTE_HTML',
        text: 'QUOTE_TEXT',
      });
      vi.spyOn(__, 'callApi')
        .mockReturnValueOnce(thread)
        .mockReturnValueOnce({
          id: 'd1',
          message: { id: 'm1', threadId: 't1' },
        });
    });

    it('reads the aliases of the account', async () => {
      await draftCreate({ ...replyOptions, account: 'perso' });

      expect(__.getAliases).toHaveBeenCalledWith('perso');
    });

    it('reads the thread with the full format', async () => {
      await draftCreate(replyOptions);

      expect(__.callApi).toHaveBeenNthCalledWith(1, 'threads/t1', {
        query: { format: 'full' },
      });
    });

    it('quotes the date, the sender and the bodies of the last Mail', async () => {
      await draftCreate(replyOptions);

      expect(__.extractBodies).toHaveBeenCalledWith(thread.messages[0].payload);
      expect(__.buildQuote).toHaveBeenCalledWith({
        date: 'Mon, 26 Oct 2026 10:05:00 +0100',
        from: 'Bob <bob@example.com>',
        text: 'orig',
        html: '<p>orig</p>',
      });
    });

    it('builds the raw mail from the last Mail', async () => {
      await draftCreate(replyOptions);

      expect(__.buildRaw).toHaveBeenCalledWith({
        from: 'work@example.com',
        to: 'Bob <bob@example.com>',
        cc: 'Carol <carol@example.com>, dave@example.com',
        subject: 'Re: Hello',
        body: 'hi',
        quote: { html: 'QUOTE_HTML', text: 'QUOTE_TEXT' },
        inReplyTo: '<m2@example.com>',
        references: '<m1@example.com> <m2@example.com>',
      });
    });

    it('posts the draft with the thread id', async () => {
      await draftCreate(replyOptions);

      expect(__.callApi).toHaveBeenNthCalledWith(2, 'drafts', {
        method: 'POST',
        body: { message: { raw: 'RAW', threadId: 't1' } },
      });
    });

    it('lets --to and --subject override the computed values', async () => {
      await draftCreate({
        ...replyOptions,
        to: 'c@example.com',
        subject: 'Other',
      });

      expect(__.buildRaw).toHaveBeenCalledWith({
        from: 'work@example.com',
        to: 'c@example.com',
        cc: 'Carol <carol@example.com>, dave@example.com',
        subject: 'Other',
        body: 'hi',
        quote: { html: 'QUOTE_HTML', text: 'QUOTE_TEXT' },
        inReplyTo: '<m2@example.com>',
        references: '<m1@example.com> <m2@example.com>',
      });
    });
  });

  it.each([
    { title: '--to', missing: 'to', code: 'GMAIL_TO_MISSING' },
    { title: '--subject', missing: 'subject', code: 'GMAIL_SUBJECT_MISSING' },
    { title: '--body', missing: 'body', code: 'GMAIL_BODY_MISSING' },
  ])('fails with $code when $title is missing', async ({ missing, code }) => {
    let actual = null;
    try {
      await draftCreate({ ...options, [missing]: undefined });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', code);
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
