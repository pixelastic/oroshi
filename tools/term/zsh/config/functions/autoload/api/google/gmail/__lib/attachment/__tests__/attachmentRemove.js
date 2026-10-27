import { __, attachmentRemove } from '../attachmentRemove.js';

describe('attachmentRemove', () => {
  const existing = [
    {
      filename: 'report.pdf',
      contentType: 'application/pdf',
      content: Buffer.from('PDF'),
    },
    {
      filename: 'a.png',
      contentType: 'image/png',
      content: Buffer.from('PNG'),
    },
    {
      filename: 'b.txt',
      contentType: 'text/plain',
      content: Buffer.from('TXT'),
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
  // The Draft in full format, with the parts of its payload
  const fullDraft = {
    id: 'd1',
    message: {
      payload: {
        partId: '',
        mimeType: 'multipart/mixed',
        parts: [
          { partId: '0', mimeType: 'multipart/alternative' },
          {
            partId: '1',
            filename: 'report.pdf',
            mimeType: 'application/pdf',
            body: { attachmentId: 'x1', size: 3 },
          },
          {
            partId: '2',
            filename: 'a.png',
            mimeType: 'image/png',
            body: { attachmentId: 'x2', size: 3 },
          },
          {
            partId: '3',
            filename: 'b.txt',
            mimeType: 'text/plain',
            body: { attachmentId: 'x3', size: 3 },
          },
        ],
      },
    },
  };
  const savedAttachments = [
    {
      partId: '1',
      filename: 'report.pdf',
      mimeType: 'application/pdf',
      size: 3,
    },
    { partId: '2', filename: 'b.txt', mimeType: 'text/plain', size: 3 },
  ];

  beforeEach(() => {
    vi.spyOn(__, 'loadDraft').mockReturnValue(draft);
    vi.spyOn(__, 'getDraft').mockReturnValue(fullDraft);
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

  it('removes the attachment with the given partId and keeps the others', async () => {
    await attachmentRemove({ draftId: 'd1', partId: '2' });

    expect(__.buildRaw).toHaveBeenCalledWith({
      from: 'me@example.com',
      to: 'you@example.com',
      cc: 'carol@example.com',
      subject: 'Hello',
      body: 'hi there',
      html: '<p>hi there</p>',
      inReplyTo: '<m2@example.com>',
      references: '<m1@example.com> <m2@example.com>',
      attachments: [existing[0], existing[2]],
    });
  });

  it.each([
    { title: 'the first', partId: '1', expected: [1, 2] },
    { title: 'the last', partId: '3', expected: [0, 1] },
  ])('removes $title attachment', async ({ partId, expected }) => {
    await attachmentRemove({ draftId: 'd1', partId });

    const { attachments } = __.buildRaw.mock.calls[0][0];
    expect(attachments).toEqual([existing[expected[0]], existing[expected[1]]]);
  });

  it('reads the Draft in full format to list the partId values', async () => {
    await attachmentRemove({ draftId: 'd1', partId: '2' });

    expect(__.getDraft).toHaveBeenCalledWith('d1', 'full');
    expect(__.loadDraft).toHaveBeenCalledWith('d1');
  });

  it('saves the MIME in the Thread of the Draft', async () => {
    await attachmentRemove({ draftId: 'd1', partId: '2' });

    expect(__.saveDraft).toHaveBeenCalledWith({
      draftId: 'd1',
      threadId: 't1',
      mime: Buffer.from('MIME'),
    });
  });

  it('fails with GMAIL_ATTACHMENT_NOT_FOUND and saves nothing for an unknown partId', async () => {
    let actual = null;
    try {
      await attachmentRemove({ draftId: 'd1', partId: '9' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_ATTACHMENT_NOT_FOUND');
    expect(__.buildRaw).not.toHaveBeenCalled();
    expect(__.saveDraft).not.toHaveBeenCalled();
  });

  it.each([
    {
      title: 'the draftId is missing',
      input: { partId: '2' },
      expected: 'GMAIL_DRAFT_ID_MISSING',
    },
    {
      title: 'the partId is missing',
      input: { draftId: 'd1' },
      expected: 'GMAIL_PART_ID_MISSING',
    },
  ])('fails with $expected when $title', async ({ input, expected }) => {
    let actual = null;
    try {
      await attachmentRemove(input);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', expected);
    expect(__.loadDraft).not.toHaveBeenCalled();
  });

  it('returns the ids, the url and the attachments left, with their new partId', async () => {
    const actual = await attachmentRemove({ draftId: 'd1', partId: '2' });

    expect(__.draftRead).toHaveBeenCalledWith({ draftId: 'd1' });
    expect(actual).toEqual({
      draftId: 'd1',
      threadId: 't1',
      url: 'https://mail.google.com/mail/u/0/#drafts?compose=m2',
      attachments: savedAttachments,
    });
  });
});
