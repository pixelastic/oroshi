import { __, draftCreate } from '../draftCreate.js';

describe('draftCreate', () => {
  const options = { to: 'a@example.com', subject: 'Hello', body: 'hi' };

  beforeEach(() => {
    vi.spyOn(__, 'buildRaw').mockReturnValue('RAW');
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'd1',
      message: { id: 'm1', threadId: 't1' },
    });
  });

  it('builds the raw mail from the options', async () => {
    await draftCreate(options);

    expect(__.buildRaw).toHaveBeenCalledWith(options);
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
      vi.spyOn(__, 'callApi')
        .mockReturnValueOnce(thread)
        .mockReturnValueOnce({
          id: 'd1',
          message: { id: 'm1', threadId: 't1' },
        });
    });

    it('reads the thread with the metadata format', async () => {
      await draftCreate(replyOptions);

      expect(__.callApi).toHaveBeenNthCalledWith(
        1,
        expect.stringMatching(/^threads\/t1\?format=metadata&.*Message-ID/),
      );
    });

    it('builds the raw mail from the last Mail', async () => {
      await draftCreate(replyOptions);

      expect(__.buildRaw).toHaveBeenCalledWith({
        to: 'Bob <bob@example.com>',
        subject: 'Re: Hello',
        body: 'hi',
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
        to: 'c@example.com',
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
