import MailComposer from 'nodemailer/lib/mail-composer/index.js';
import { __, loadDraft } from '../loadDraft.js';

describe('loadDraft', () => {
  const compose = async (options) =>
    await new MailComposer(options).compile().build();

  const mockDraft = async (options) => {
    const mime = await compose(options);
    vi.spyOn(__, 'getDraft').mockReturnValue({
      id: 'd1',
      message: { id: 'm1', threadId: 't1', raw: mime.toString('base64url') },
    });
  };

  const baseMail = {
    from: 'me@example.com',
    to: 'you@example.com',
    cc: 'Carol <carol@example.com>',
    subject: 'Hello',
    text: 'hi there',
    inReplyTo: '<m2@example.com>',
    references: '<m1@example.com> <m2@example.com>',
  };

  it('reads the Draft in raw format', async () => {
    await mockDraft(baseMail);

    await loadDraft('d1');

    expect(__.getDraft).toHaveBeenCalledWith('d1', 'raw');
  });

  it('returns the ids and the fields of the Draft', async () => {
    await mockDraft(baseMail);

    const actual = await loadDraft('d1');

    expect(actual).toMatchObject({
      draftId: 'd1',
      threadId: 't1',
      from: 'me@example.com',
      to: 'you@example.com',
      cc: '"Carol" <carol@example.com>',
      subject: 'Hello',
      inReplyTo: '<m2@example.com>',
      references: '<m1@example.com> <m2@example.com>',
    });
    expect(actual.text.trim()).toEqual('hi there');
  });

  it('returns a single reference as it is', async () => {
    await mockDraft({ ...baseMail, references: '<m1@example.com>' });

    const actual = await loadDraft('d1');

    expect(actual).toHaveProperty('references', '<m1@example.com>');
  });

  it('returns empty strings for the missing address headers', async () => {
    await mockDraft({ to: 'you@example.com', subject: 'Hello', text: 'hi' });

    const actual = await loadDraft('d1');

    expect(actual).toHaveProperty('cc', '');
    expect(actual).toHaveProperty('from', '');
  });

  it('returns the HTML without the wrapper of the raw builder', async () => {
    await mockDraft({
      ...baseMail,
      html: '<div dir="ltr"><ul><li>one</li></ul></div>',
    });

    const actual = await loadDraft('d1');

    expect(actual).toHaveProperty('html', '<ul><li>one</li></ul>');
  });

  it('returns the attachments in the format of the raw builder', async () => {
    await mockDraft({
      ...baseMail,
      attachments: [
        {
          filename: 'report.pdf',
          contentType: 'application/pdf',
          content: Buffer.from('PDF-BYTES'),
        },
      ],
    });

    const actual = await loadDraft('d1');

    expect(actual).toHaveProperty('attachments', [
      {
        filename: 'report.pdf',
        contentType: 'application/pdf',
        content: Buffer.from('PDF-BYTES'),
        contentDisposition: 'attachment',
      },
    ]);
  });

  it('keeps the cid links of the inline attachments', async () => {
    await mockDraft({
      ...baseMail,
      html: '<img src="cid:logo">',
      attachments: [
        {
          filename: 'logo.png',
          contentType: 'image/png',
          content: Buffer.from('PNG'),
          cid: 'logo',
        },
      ],
    });

    const actual = await loadDraft('d1');

    expect(actual.html).toContain('cid:logo');
    expect(actual).toHaveProperty('attachments.0.cid', 'logo');
  });
});
