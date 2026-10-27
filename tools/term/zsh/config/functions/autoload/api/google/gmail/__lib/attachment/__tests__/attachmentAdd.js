import { __, attachmentAdd } from '../attachmentAdd.js';

describe('attachmentAdd', () => {
  const existing = [
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
    attachments: existing,
  };
  const savedAttachments = [
    {
      partId: '1',
      filename: 'report.pdf',
      mimeType: 'application/pdf',
      size: 3,
    },
    { partId: '2', filename: 'a.png', mimeType: 'image/png', size: 1 },
    { partId: '3', filename: 'b.txt', mimeType: 'text/plain', size: 1 },
  ];

  beforeEach(() => {
    vi.spyOn(__, 'loadDraft').mockReturnValue(draft);
    vi.spyOn(__, 'isFile').mockReturnValue(true);
    vi.spyOn(__, 'readFile').mockImplementation((filepath) =>
      Buffer.from(`content of ${filepath}`),
    );
    vi.spyOn(__, 'checkAttachmentsSize').mockReturnValue();
    vi.spyOn(__, 'buildRaw').mockReturnValue(Buffer.from('MIME'));
    vi.spyOn(__, 'saveDraft').mockReturnValue({
      id: 'd1',
      message: { id: 'm2', threadId: 't1' },
    });
    vi.spyOn(__, 'draftRead').mockReturnValue({
      draftId: 'd1',
      attachments: savedAttachments,
    });
  });

  it('adds several files in one call, after the existing attachments', async () => {
    await attachmentAdd({
      draftId: 'd1',
      files: ['/tmp/a.png', '/docs/b.txt'],
    });

    expect(__.buildRaw).toHaveBeenCalledWith({
      from: 'me@example.com',
      to: 'you@example.com',
      cc: 'carol@example.com',
      subject: 'Hello',
      body: 'hi there',
      html: '<p>hi there</p>',
      inReplyTo: '<m2@example.com>',
      references: '<m1@example.com> <m2@example.com>',
      attachments: [
        ...existing,
        { filename: 'a.png', content: Buffer.from('content of /tmp/a.png') },
        { filename: 'b.txt', content: Buffer.from('content of /docs/b.txt') },
      ],
    });
  });

  it('adds 9 files in one call', async () => {
    const files = Array.from({ length: 9 }, (_value, index) => {
      return `/tmp/file-${index}.txt`;
    });

    await attachmentAdd({ draftId: 'd1', files });

    const { attachments } = __.buildRaw.mock.calls[0][0];
    expect(attachments).toHaveLength(10);
    expect(__.saveDraft).toHaveBeenCalledTimes(1);
  });

  it('checks the size of the existing and the new attachments together', async () => {
    await attachmentAdd({ draftId: 'd1', files: ['/tmp/a.png'] });

    expect(__.checkAttachmentsSize).toHaveBeenCalledWith([
      ...existing,
      { filename: 'a.png', content: Buffer.from('content of /tmp/a.png') },
    ]);
  });

  it('fails before any save when the attachments are too large', async () => {
    vi.spyOn(__, 'checkAttachmentsSize').mockImplementation(() => {
      throw new Error('GMAIL_ATTACHMENTS_TOO_LARGE');
    });

    let actual = null;
    try {
      await attachmentAdd({ draftId: 'd1', files: ['/tmp/a.png'] });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'GMAIL_ATTACHMENTS_TOO_LARGE');
    expect(__.buildRaw).not.toHaveBeenCalled();
    expect(__.saveDraft).not.toHaveBeenCalled();
  });

  it('fails with GMAIL_ATTACHMENT_FILE_NOT_FOUND when a file is missing', async () => {
    vi.spyOn(__, 'isFile').mockImplementation((filepath) => {
      return filepath !== '/tmp/missing.png';
    });

    let actual = null;
    try {
      await attachmentAdd({
        draftId: 'd1',
        files: ['/tmp/a.png', '/tmp/missing.png'],
      });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_ATTACHMENT_FILE_NOT_FOUND');
    expect(__.loadDraft).not.toHaveBeenCalled();
    expect(__.saveDraft).not.toHaveBeenCalled();
  });

  it.each([
    {
      title: 'an empty list',
      options: { draftId: 'd1', files: [] },
      expected: 'GMAIL_ATTACHMENT_FILES_MISSING',
    },
    {
      title: 'no list',
      options: { draftId: 'd1', files: undefined },
      expected: 'GMAIL_ATTACHMENT_FILES_MISSING',
    },
    {
      title: 'no draftId',
      options: { files: ['/tmp/a.png'] },
      expected: 'GMAIL_DRAFT_ID_MISSING',
    },
  ])('fails with $expected with $title', async ({ options, expected }) => {
    let actual = null;
    try {
      await attachmentAdd(options);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', expected);
    expect(__.loadDraft).not.toHaveBeenCalled();
  });

  it('saves the MIME in the Thread of the Draft', async () => {
    await attachmentAdd({ draftId: 'd1', files: ['/tmp/a.png'] });

    expect(__.loadDraft).toHaveBeenCalledWith('d1');
    expect(__.saveDraft).toHaveBeenCalledWith({
      draftId: 'd1',
      threadId: 't1',
      mime: Buffer.from('MIME'),
    });
  });

  it('returns the ids, the url and the current attachments', async () => {
    const actual = await attachmentAdd({
      draftId: 'd1',
      files: ['/tmp/a.png', '/docs/b.txt'],
    });

    expect(__.draftRead).toHaveBeenCalledWith({ draftId: 'd1' });
    expect(actual).toEqual({
      draftId: 'd1',
      threadId: 't1',
      url: 'https://mail.google.com/mail/u/0/#drafts?compose=m2',
      attachments: savedAttachments,
    });
  });
});
