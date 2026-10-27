import { __, draftUpdate } from '../draftUpdate.js';

describe('draftUpdate', () => {
  const attachments = [
    {
      filename: 'report.pdf',
      contentType: 'application/pdf',
      content: Buffer.from('PDF'),
    },
  ];
  const draft = {
    draftId: 'd1',
    threadId: 't1',
    from: 'me@example.com',
    to: 'you@example.com',
    cc: 'carol@example.com',
    subject: 'Hello',
    inReplyTo: '<m2@example.com>',
    references: '<m1@example.com> <m2@example.com>',
    text: 'hi there',
    html: '<p>hi there</p>',
    attachments,
  };
  const savedAttachments = [
    {
      partId: '1',
      filename: 'report.pdf',
      mimeType: 'application/pdf',
      size: 3,
    },
  ];

  beforeEach(() => {
    vi.spyOn(__, 'loadDraft').mockReturnValue(draft);
    vi.spyOn(__, 'buildRaw').mockReturnValue(Buffer.from('MIME'));
    vi.spyOn(__, 'saveDraft').mockReturnValue({
      id: 'd1',
      message: { id: 'm2', threadId: 't1' },
    });
    vi.spyOn(__, 'draftRead').mockReturnValue({
      draftId: 'd1',
      attachments: savedAttachments,
    });
    vi.spyOn(__, 'read').mockReturnValue('# Title');
  });

  it('loads the Draft by its id', async () => {
    await draftUpdate({ draftId: 'd1', subject: 'New' });

    expect(__.loadDraft).toHaveBeenCalledWith('d1');
  });

  it('keeps the value of an absent flag', async () => {
    await draftUpdate({ draftId: 'd1', subject: 'New' });

    expect(__.buildRaw).toHaveBeenCalledWith({
      from: 'me@example.com',
      to: 'you@example.com',
      cc: 'carol@example.com',
      subject: 'New',
      body: 'hi there',
      html: '<p>hi there</p>',
      inReplyTo: '<m2@example.com>',
      references: '<m1@example.com> <m2@example.com>',
      attachments,
    });
  });

  it.each([
    { title: '--to', options: { to: 'c@example.com' }, field: 'to' },
    { title: '--subject', options: { subject: 'New' }, field: 'subject' },
  ])('replaces the value with $title', async ({ options, field }) => {
    await draftUpdate({ draftId: 'd1', ...options });

    expect(__.buildRaw).toHaveBeenCalledWith(
      expect.objectContaining({ [field]: options[field] }),
    );
  });

  it('replaces the body, and drops the old HTML, with --body', async () => {
    await draftUpdate({ draftId: 'd1', body: 'new body' });

    expect(__.buildRaw).toHaveBeenCalledWith(
      expect.objectContaining({ body: 'new body', html: undefined }),
    );
  });

  it('replaces the body and the HTML with a .md --body-file', async () => {
    await draftUpdate({ draftId: 'd1', bodyFile: '/tmp/body.md' });

    expect(__.read).toHaveBeenCalledWith('/tmp/body.md');
    expect(__.buildRaw).toHaveBeenCalledWith(
      expect.objectContaining({
        body: '# Title',
        html: expect.stringContaining('<h1>Title</h1>'),
      }),
    );
  });

  it('keeps the existing attachments', async () => {
    await draftUpdate({ draftId: 'd1', body: 'new body' });

    expect(__.buildRaw).toHaveBeenCalledWith(
      expect.objectContaining({ attachments }),
    );
  });

  it('saves the MIME in the Thread of the Draft', async () => {
    await draftUpdate({ draftId: 'd1', subject: 'New' });

    expect(__.saveDraft).toHaveBeenCalledWith({
      draftId: 'd1',
      threadId: 't1',
      mime: Buffer.from('MIME'),
    });
  });

  it('returns the ids, the url and the attachments of the saved Draft', async () => {
    const actual = await draftUpdate({ draftId: 'd1', subject: 'New' });

    expect(__.draftRead).toHaveBeenCalledWith({ draftId: 'd1' });
    expect(actual).toEqual({
      draftId: 'd1',
      threadId: 't1',
      url: 'https://mail.google.com/mail/u/0/#drafts?compose=m2',
      attachments: savedAttachments,
    });
  });

  it('fails with GMAIL_UPDATE_EMPTY when no flag changes the Draft', async () => {
    let actual = null;
    try {
      await draftUpdate({ draftId: 'd1' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_UPDATE_EMPTY');
    expect(__.loadDraft).not.toHaveBeenCalled();
    expect(__.saveDraft).not.toHaveBeenCalled();
  });

  it('fails with GMAIL_BODY_CONFLICT when both body flags are given', async () => {
    let actual = null;
    try {
      await draftUpdate({
        draftId: 'd1',
        body: 'hi',
        bodyFile: '/tmp/body.md',
      });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_BODY_CONFLICT');
    expect(__.saveDraft).not.toHaveBeenCalled();
  });

  it('fails with GMAIL_DRAFT_ID_MISSING when the draftId is missing', async () => {
    let actual = null;
    try {
      await draftUpdate({ subject: 'New' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_DRAFT_ID_MISSING');
    expect(__.loadDraft).not.toHaveBeenCalled();
  });
});
