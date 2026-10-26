import { firostError } from 'firost';
import { __, messageRead } from '../messageRead.js';

describe('messageRead', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'c1',
      messages: [
        { id: 'm3', internalDate: '3000' },
        { id: 'm1', internalDate: '1000' },
        { id: 'm2', internalDate: '2000' },
      ],
    });
    vi.spyOn(__, 'formatMail').mockImplementation((mail) => ({ id: mail.id }));
  });

  it('asks for the full format of the Message', async () => {
    await messageRead({ messageId: 'c1' });

    expect(__.callApi).toHaveBeenCalledWith('threads/c1', {
      query: { format: 'full' },
    });
  });

  it('returns one formatted item per mail, oldest first', async () => {
    const actual = await messageRead({ messageId: 'c1' });

    expect(actual).toEqual([{ id: 'm1' }, { id: 'm2' }, { id: 'm3' }]);
  });

  it('fails when the id is missing', async () => {
    let actual = null;
    try {
      await messageRead({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_MESSAGE_ID_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('fails when the id is unknown', async () => {
    vi.spyOn(__, 'callApi').mockImplementation(() => {
      throw firostError(
        'GMAIL_REQUEST_FAILED',
        'Requested entity was not found',
      );
    });

    let actual = null;
    try {
      await messageRead({ messageId: 'unknown' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_REQUEST_FAILED');
  });
});
