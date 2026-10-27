import { firostError } from 'firost';
import { __, getDraftIds } from '../getDraftIds.js';

describe('getDraftIds', () => {
  it('maps the id of each Message to the id of its Draft', async () => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      drafts: [
        { id: 'd1', message: { id: 'm1', threadId: 't1' } },
        { id: 'd2', message: { id: 'm2', threadId: 't2' } },
      ],
    });

    const actual = await getDraftIds();

    expect(__.callApi).toHaveBeenCalledWith('drafts', { query: {} });
    expect(actual).toEqual({ m1: 'd1', m2: 'd2' });
  });

  it('gives an empty map when there is no Draft', async () => {
    vi.spyOn(__, 'callApi').mockReturnValue({});

    const actual = await getDraftIds();

    expect(actual).toEqual({});
  });

  it('follows the pagination of the list', async () => {
    vi.spyOn(__, 'callApi').mockImplementation((_path, { query }) => {
      if (query.pageToken === 'next') {
        return { drafts: [{ id: 'd2', message: { id: 'm2' } }] };
      }
      return {
        drafts: [{ id: 'd1', message: { id: 'm1' } }],
        nextPageToken: 'next',
      };
    });

    const actual = await getDraftIds();

    expect(__.callApi).toHaveBeenCalledTimes(2);
    expect(__.callApi).toHaveBeenLastCalledWith('drafts', {
      query: { pageToken: 'next' },
    });
    expect(actual).toEqual({ m1: 'd1', m2: 'd2' });
  });

  it('lets the errors of the list through', async () => {
    vi.spyOn(__, 'callApi').mockImplementation(() => {
      throw firostError('GMAIL_REQUEST_FAILED', '500 Backend error');
    });

    let actual = null;
    try {
      await getDraftIds();
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_REQUEST_FAILED');
  });
});
