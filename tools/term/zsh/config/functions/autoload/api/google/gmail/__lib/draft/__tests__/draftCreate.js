import { firostError } from 'firost';
import { __, draftCreate } from '../draftCreate.js';

describe('draftCreate', () => {
  const options = { to: 'a@example.com', subject: 'Hello', body: 'hi' };

  beforeEach(() => {
    vi.spyOn(__, 'buildRaw').mockReturnValue(Buffer.from('RAW'));
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'd1',
      message: { id: 'm1', threadId: 't1' },
    });
    vi.spyOn(__, 'getAliases').mockReturnValue([
      'me@example.com',
      'work@example.com',
    ]);
  });

  it('does not read the aliases without --threadId', async () => {
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

  it('posts the raw mail, in base64url, to drafts.create', async () => {
    await draftCreate(options);

    expect(__.callApi).toHaveBeenCalledWith('drafts', {
      method: 'POST',
      body: { message: { raw: Buffer.from('RAW').toString('base64url') } },
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

  describe('with --threadId', () => {
    const replyOptions = { threadId: 't1', body: 'hi' };
    const thread = {
      id: 't1',
      messages: [
        {
          id: 'm2',
          internalDate: '3000',
          payload: {
            headers: [
              { name: 'From', value: 'Bob <bob@example.com>' },
              {
                name: 'To',
                value: 'Carol <carol@example.com>, work@example.com',
              },
              { name: 'Cc', value: 'dave@example.com, me@example.com' },
              { name: 'Subject', value: 'Re: Hello' },
              { name: 'Message-ID', value: '<m2@example.com>' },
              { name: 'References', value: '<m1@example.com>' },
            ],
          },
        },
        {
          id: 'm1',
          internalDate: '2000',
          payload: {
            headers: [
              { name: 'From', value: 'Carol <carol@example.com>' },
              { name: 'Subject', value: 'Re: Hello' },
              { name: 'Message-ID', value: '<m1b@example.com>' },
            ],
          },
        },
        {
          id: 'm0',
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
      vi.spyOn(__, 'getThread').mockReturnValue(thread);
    });

    it('reads the aliases of the account', async () => {
      await draftCreate(replyOptions);

      expect(__.getAliases).toHaveBeenCalled();
    });

    it('reads the Thread by its id with the full format', async () => {
      await draftCreate(replyOptions);

      expect(__.getThread).toHaveBeenCalledTimes(1);
      expect(__.getThread).toHaveBeenCalledWith('t1', {
        query: { format: 'full' },
      });
    });

    it('builds the raw mail from the last Message', async () => {
      await draftCreate(replyOptions);

      expect(__.buildRaw).toHaveBeenCalledWith({
        from: 'work@example.com',
        to: 'Bob <bob@example.com>',
        cc: 'Carol <carol@example.com>, dave@example.com',
        subject: 'Re: Hello',
        body: 'hi',
        inReplyTo: '<m2@example.com>',
        references: '<m1@example.com> <m2@example.com>',
      });
    });

    it('posts the draft with the Thread id', async () => {
      await draftCreate(replyOptions);

      expect(__.callApi).toHaveBeenCalledTimes(1);
      expect(__.callApi).toHaveBeenCalledWith('drafts', {
        method: 'POST',
        body: {
          message: {
            raw: Buffer.from('RAW').toString('base64url'),
            threadId: 't1',
          },
        },
      });
    });

    it('throws GMAIL_THREAD_NOT_FOUND when the Thread does not exist', async () => {
      vi.spyOn(__, 'getThread').mockImplementation(() => {
        throw firostError('GMAIL_THREAD_NOT_FOUND', 'Thread t1 not found');
      });

      let actual = null;
      try {
        await draftCreate(replyOptions);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GMAIL_THREAD_NOT_FOUND');
      expect(__.callApi).not.toHaveBeenCalled();
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
