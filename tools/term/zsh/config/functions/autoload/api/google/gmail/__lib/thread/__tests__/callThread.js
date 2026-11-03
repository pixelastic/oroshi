import { firostError } from 'firost';
import { __, callThread } from '../callThread.js';

describe('callThread', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 't1' });
  });

  it.each([
    {
      title: 'without body',
      input: { action: 'trash' },
      expected: { method: 'POST' },
    },
    {
      title: 'with body',
      input: { action: 'modify', body: { addLabelIds: ['Label_1'] } },
      expected: { method: 'POST', body: { addLabelIds: ['Label_1'] } },
    },
  ])('posts the action of the Thread $title', async ({ input, expected }) => {
    await callThread({ threadId: 't1', ...input });

    expect(__.callApi).toHaveBeenCalledWith(
      `threads/t1/${input.action}`,
      expected,
    );
  });

  it('returns the answer of the API', async () => {
    const actual = await callThread({ threadId: 't1', action: 'trash' });

    expect(actual).toEqual({ id: 't1' });
  });

  it.each([
    {
      title: 'the API answers 404',
      apiError: firostError(
        'GMAIL_REQUEST_FAILED',
        '404 {"error":"NOT_FOUND"}',
      ),
      expected: 'GMAIL_THREAD_NOT_FOUND',
    },
    {
      title: 'the API answers any other error',
      apiError: firostError('GMAIL_REQUEST_FAILED', '500 oops'),
      expected: 'GMAIL_REQUEST_FAILED',
    },
  ])('fails with $expected when $title', async ({ apiError, expected }) => {
    __.callApi.mockImplementation(() => {
      throw apiError;
    });

    let actual = null;
    try {
      await callThread({ threadId: 't1', action: 'trash' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', expected);
  });
});
