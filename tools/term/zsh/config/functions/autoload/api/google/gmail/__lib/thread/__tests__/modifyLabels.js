import { firostError } from 'firost';
import { __, modifyLabels } from '../modifyLabels.js';

describe('modifyLabels', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 't1', messages: [] });
  });

  it.each([
    {
      title: 'adds labels',
      input: { add: ['Label_1'] },
      expected: { addLabelIds: ['Label_1'] },
    },
    {
      title: 'removes labels',
      input: { remove: ['Label_1'] },
      expected: { removeLabelIds: ['Label_1'] },
    },
    {
      title: 'adds and removes labels',
      input: { add: ['Label_1'], remove: ['UNREAD'] },
      expected: { addLabelIds: ['Label_1'], removeLabelIds: ['UNREAD'] },
    },
  ])('$title', async ({ input, expected }) => {
    await modifyLabels({ threadId: 't1', ...input });

    expect(__.callApi).toHaveBeenCalledWith('threads/t1/modify', {
      method: 'POST',
      body: expected,
    });
  });

  it('returns the Thread as the API answers it', async () => {
    const actual = await modifyLabels({ threadId: 't1', add: ['Label_1'] });

    expect(actual).toEqual({ id: 't1', messages: [] });
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
      await modifyLabels({ threadId: 't1', add: ['Label_1'] });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', expected);
  });
});
