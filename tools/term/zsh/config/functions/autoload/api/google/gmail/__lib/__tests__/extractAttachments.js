import { extractAttachments } from '../extractAttachments.js';

describe('extractAttachments', () => {
  it('returns an empty list without a part', () => {
    expect(extractAttachments(undefined)).toEqual([]);
  });

  it('lists the attachments, including nested ones', () => {
    const actual = extractAttachments({
      mimeType: 'multipart/mixed',
      parts: [
        { mimeType: 'text/plain', body: { data: 'aGk' } },
        {
          partId: '1',
          mimeType: 'multipart/alternative',
          parts: [
            {
              partId: '1.2',
              filename: 'report.pdf',
              mimeType: 'application/pdf',
              body: { attachmentId: 'att-1', size: 42 },
            },
          ],
        },
      ],
    });

    expect(actual).toEqual([
      {
        partId: '1.2',
        attachmentId: 'att-1',
        filename: 'report.pdf',
        mimeType: 'application/pdf',
        size: 42,
      },
    ]);
  });

  it('skips parts without a filename or an attachment id', () => {
    const actual = extractAttachments({
      parts: [
        { filename: '', body: { attachmentId: 'x' } },
        { filename: 'inline.txt', body: { data: 'aGk' } },
      ],
    });

    expect(actual).toEqual([]);
  });
});
