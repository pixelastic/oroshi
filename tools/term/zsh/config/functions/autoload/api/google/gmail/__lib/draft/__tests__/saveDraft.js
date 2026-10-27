import { __, saveDraft } from '../saveDraft.js';

describe('saveDraft', () => {
  const mime = Buffer.from('Subject: Hello\r\n\r\nhi é');

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'd1',
      message: { id: 'm2', threadId: 't1' },
    });
  });

  const lastCall = () => __.callApi.mock.calls[0];

  it('puts to the upload endpoint of the Draft', async () => {
    await saveDraft({ draftId: 'd1', threadId: 't1', mime });

    const [path, options] = lastCall();
    expect(path).toEqual('drafts/d1');
    expect(options).toHaveProperty('method', 'PUT');
    expect(options).toHaveProperty(
      'baseUrl',
      'https://gmail.googleapis.com/upload/gmail/v1/users/me',
    );
    expect(options).toHaveProperty('query', { uploadType: 'multipart' });
  });

  it('sends a multipart/related body, with its boundary in the header', async () => {
    await saveDraft({ draftId: 'd1', threadId: 't1', mime });

    const { headers, body } = lastCall()[1];
    const boundary = headers['Content-Type'].match(
      /^multipart\/related; boundary=(.+)$/,
    )[1];
    expect(Buffer.isBuffer(body)).toEqual(true);
    expect(body.toString('utf8')).toContain(`--${boundary}--`);
  });

  it('sends the Thread id in a JSON part', async () => {
    await saveDraft({ draftId: 'd1', threadId: 't1', mime });

    const body = lastCall()[1].body.toString('utf8');
    expect(body).toContain('Content-Type: application/json; charset=UTF-8');
    expect(body).toContain(JSON.stringify({ message: { threadId: 't1' } }));
  });

  it('sends the MIME untouched in a message/rfc822 part', async () => {
    await saveDraft({ draftId: 'd1', threadId: 't1', mime });

    const body = lastCall()[1].body;
    expect(body.toString('utf8')).toContain('Content-Type: message/rfc822');
    expect(body.indexOf(mime)).toBeGreaterThan(-1);
  });

  it('returns the saved Draft', async () => {
    const actual = await saveDraft({ draftId: 'd1', threadId: 't1', mime });

    expect(actual).toEqual({
      id: 'd1',
      message: { id: 'm2', threadId: 't1' },
    });
  });
});
