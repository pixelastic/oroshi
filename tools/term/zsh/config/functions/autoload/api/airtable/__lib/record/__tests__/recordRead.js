import { firostError } from 'firost';
import { __, recordRead } from '../recordRead.js';

describe('recordRead', () => {
  const response = {
    id: 'recA',
    createdTime: '2026-03-12T10:00:00.000Z',
    fields: { Name: 'Paris Meetup' },
  };

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue(response);
    vi.spyOn(__, 'formatRecord').mockReturnValue({ id: 'formatted' });
  });

  it('calls the API with the anchors and the id of the Record', async () => {
    await recordRead({
      recordId: 'recA',
      baseId: 'appDEVREL',
      tableId: 'My Meetups',
    });

    expect(__.callApi).toHaveBeenCalledWith('appDEVREL/My%20Meetups/recA');
  });

  it('returns the response of the API, formatted', async () => {
    const actual = await recordRead({
      recordId: 'recA',
      baseId: 'appDEVREL',
      tableId: 'tblMEETUPS',
    });

    expect(__.formatRecord).toHaveBeenCalledWith(response);
    expect(actual).toEqual({ id: 'formatted' });
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
      await recordRead(options);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', code);
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('surfaces the failure of the API for an unknown Record', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('AIRTABLE_REQUEST_FAILED', 'NOT_FOUND');
    });

    let actual = null;
    try {
      await recordRead({
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
