import { __, draftRead } from '../draftRead.js';

describe('draftRead', () => {
  const draft = {
    id: 'd1',
    message: {
      id: 'm1',
      threadId: 't1',
      snippet: 'Hello there',
      payload: {
        partId: '',
        mimeType: 'multipart/mixed',
        headers: [
          { name: 'From', value: 'me@example.com' },
          { name: 'To', value: 'you@example.com' },
          { name: 'Subject', value: 'Hello' },
          { name: 'Date', value: 'Mon, 1 Jan 2026 10:00:00 +0000' },
        ],
        parts: [
          {
            partId: '0',
            mimeType: 'text/plain',
            filename: '',
            body: { size: 5, data: Buffer.from('Hello').toString('base64url') },
          },
          {
            partId: '1',
            mimeType: 'application/pdf',
            filename: 'report.pdf',
            body: { size: 1234, attachmentId: 'att-1' },
          },
        ],
      },
    },
  };

  beforeEach(() => {
    vi.spyOn(__, 'getDraft').mockReturnValue(draft);
  });

  it('reads the Draft in full format', async () => {
    await draftRead({ draftId: 'd1' });

    expect(__.getDraft).toHaveBeenCalledWith('d1', 'full');
  });

  it('prints the Draft with its ids, headers and body', async () => {
    const actual = await draftRead({ draftId: 'd1' });

    expect(actual).toEqual({
      draftId: 'd1',
      threadId: 't1',
      messageId: 'm1',
      from: 'me@example.com',
      to: 'you@example.com',
      subject: 'Hello',
      body: 'Hello',
      attachments: expect.any(Array),
    });
  });

  it('lists the attachments without bytes and without attachmentId', async () => {
    const actual = await draftRead({ draftId: 'd1' });

    expect(actual).toHaveProperty('attachments', [
      {
        partId: '1',
        filename: 'report.pdf',
        mimeType: 'application/pdf',
        size: 1234,
      },
    ]);
  });

  it('fails with GMAIL_DRAFT_ID_MISSING when the draftId is missing', async () => {
    let actual = null;
    try {
      await draftRead({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_DRAFT_ID_MISSING');
    expect(__.getDraft).not.toHaveBeenCalled();
  });
});
