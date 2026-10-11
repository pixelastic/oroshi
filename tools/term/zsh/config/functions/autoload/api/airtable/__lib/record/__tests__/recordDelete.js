import { firostError } from 'firost';
import { __, recordDelete } from '../recordDelete.js';

describe('recordDelete', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 'recA', deleted: true });
  });

  it('sends a DELETE for the Record', async () => {
    await recordDelete({
      recordId: 'recA',
      baseId: 'appDEVREL',
      tableId: 'My Meetups',
    });

    expect(__.callApi).toHaveBeenCalledWith('appDEVREL/My%20Meetups/recA', {
      method: 'DELETE',
    });
  });

  it('returns the id it received', async () => {
    const actual = await recordDelete({
      recordId: 'recA',
      baseId: 'appDEVREL',
      tableId: 'tblMEETUPS',
    });

    expect(actual).toEqual('recA');
  });

  it.each([
    {
      title: 'Record',
      options: { baseId: 'appA', tableId: 'tblA' },
      code: 'AIRTABLE_RECORD_ID_MISSING',
    },
    {
      title: 'Base',
      options: { recordId: 'recA', tableId: 'tblA' },
      code: 'AIRTABLE_BASE_ID_MISSING',
    },
    {
      title: 'Table',
      options: { recordId: 'recA', baseId: 'appA' },
      code: 'AIRTABLE_TABLE_ID_MISSING',
    },
  ])('throws when the $title is missing', async ({ options, code }) => {
    let actual = null;
    try {
      await recordDelete(options);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', code);
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('surfaces the failure of the API', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('AIRTABLE_REQUEST_FAILED', 'NOT_FOUND');
    });

    let actual = null;
    try {
      await recordDelete({
        recordId: 'recMISSING',
        baseId: 'appDEVREL',
        tableId: 'tblMEETUPS',
      });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', 'NOT_FOUND');
  });
});
