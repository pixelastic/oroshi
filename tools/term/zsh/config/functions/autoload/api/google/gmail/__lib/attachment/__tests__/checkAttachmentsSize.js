import { checkAttachmentsSize } from '../checkAttachmentsSize.js';

describe('checkAttachmentsSize', () => {
  const MB = 1024 * 1024;

  it.each([
    {
      title: 'attachments that fit in 25 MB once in base64',
      attachments: [{ content: Buffer.alloc(18 * MB) }],
    },
    { title: 'no attachment', attachments: [] },
  ])('accepts $title', ({ attachments }) => {
    expect(() => checkAttachmentsSize(attachments)).not.toThrow();
  });

  it.each([
    {
      // 20 MB raw is below 25 MB, but about 26.7 MB in base64
      title: 'counts the base64 size, not the raw size',
      attachments: [{ content: Buffer.alloc(20 * MB) }],
    },
    {
      title: 'adds the sizes of all the attachments',
      attachments: [
        { content: Buffer.alloc(10 * MB) },
        { content: Buffer.alloc(10 * MB) },
      ],
    },
  ])('fails when it $title', ({ attachments }) => {
    let actual = null;
    try {
      checkAttachmentsSize(attachments);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_ATTACHMENTS_TOO_LARGE');
  });
});
