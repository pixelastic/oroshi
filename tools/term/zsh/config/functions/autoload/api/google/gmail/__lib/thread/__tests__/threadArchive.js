import { firostError } from 'firost';
import { __, threadArchive } from '../threadArchive.js';

describe('threadArchive', () => {
  beforeEach(() => {
    vi.spyOn(__, 'modifyLabels').mockReturnValue({ id: 't1', messages: [] });
  });

  it('removes the Thread from the Inbox', async () => {
    await threadArchive({ threadId: 't1' });

    expect(__.modifyLabels).toHaveBeenCalledWith({
      threadId: 't1',
      remove: ['INBOX'],
    });
  });

  it('returns the threadId', async () => {
    const actual = await threadArchive({ threadId: 't1' });

    expect(actual).toEqual({ threadId: 't1' });
  });

  it('fails with GMAIL_THREAD_ID_MISSING without an id, with no API call', async () => {
    let actual = null;
    try {
      await threadArchive({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_THREAD_ID_MISSING');
    expect(__.modifyLabels).not.toHaveBeenCalled();
  });

  it('lets the error of modifyLabels through', async () => {
    __.modifyLabels.mockImplementation(() => {
      throw firostError('GMAIL_THREAD_NOT_FOUND', 'Thread t1 not found');
    });

    let actual = null;
    try {
      await threadArchive({ threadId: 't1' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_THREAD_NOT_FOUND');
  });
});
