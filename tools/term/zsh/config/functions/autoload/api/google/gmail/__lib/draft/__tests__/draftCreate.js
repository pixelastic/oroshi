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
