import { firostError } from 'firost';
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
    vi.spyOn(__, 'callApi').mockReturnValue(draft);
  });

  it('reads the Draft in full format', async () => {
    await draftRead({ draftId: 'd1' });

    expect(__.callApi).toHaveBeenCalledWith('drafts/d1', {
      query: { format: 'full' },
    });
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
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('fails with GMAIL_DRAFT_NOT_FOUND on a 404', async () => {
    vi.spyOn(__, 'callApi').mockImplementation(() => {
      throw firostError(
        'GMAIL_REQUEST_FAILED',
        '404 {"error":{"message":"Requested entity was not found."}}',
      );
    });

    let actual = null;
    try {
      await draftRead({ draftId: 'unknown' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_DRAFT_NOT_FOUND');
    expect(actual).toHaveProperty('message', 'Draft unknown not found');
  });

  it('lets other errors through', async () => {
    vi.spyOn(__, 'callApi').mockImplementation(() => {
      throw firostError('GMAIL_REQUEST_FAILED', '500 Backend error');
    });

    let actual = null;
    try {
      await draftRead({ draftId: 'd1' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_REQUEST_FAILED');
  });
});
