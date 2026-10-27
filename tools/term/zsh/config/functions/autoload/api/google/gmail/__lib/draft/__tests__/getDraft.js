import { firostError } from 'firost';
import { __, getDraft } from '../getDraft.js';

describe('getDraft', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 'd1' });
  });

  it('reads the Draft in the given format', async () => {
    const actual = await getDraft('d1', 'raw');

    expect(__.callApi).toHaveBeenCalledWith('drafts/d1', {
      query: { format: 'raw' },
    });
    expect(actual).toEqual({ id: 'd1' });
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
      await getDraft('unknown', 'full');
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
      await getDraft('d1', 'full');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_REQUEST_FAILED');
  });
});
