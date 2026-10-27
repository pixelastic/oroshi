import { firostError } from 'firost';
import { __, draftDelete } from '../draftDelete.js';

describe('draftDelete', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue('');
  });

  it('deletes the Draft through the API', async () => {
    await draftDelete({ draftId: 'd1' });

    expect(__.callApi).toHaveBeenCalledWith('drafts/d1', { method: 'DELETE' });
  });

  it('returns the id of the deleted Draft', async () => {
    const actual = await draftDelete({ draftId: 'd1' });

    expect(actual).toEqual({ draftId: 'd1' });
  });

  it('fails with GMAIL_DRAFT_ID_MISSING when the draftId is missing', async () => {
    let actual = null;
    try {
      await draftDelete({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_DRAFT_ID_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('fails with GMAIL_DRAFT_NOT_FOUND when the Draft does not exist', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('GMAIL_REQUEST_FAILED', '404 {"error":"NOT_FOUND"}');
    });

    let actual = null;
    try {
      await draftDelete({ draftId: 'd1' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_DRAFT_NOT_FOUND');
  });

  it('rethrows any other error of the API', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('GMAIL_REQUEST_FAILED', '500 oops');
    });

    let actual = null;
    try {
      await draftDelete({ draftId: 'd1' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_REQUEST_FAILED');
  });
});
