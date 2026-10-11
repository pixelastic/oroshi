import { firostError } from 'firost';
import { __, recordUpdate } from '../recordUpdate.js';

describe('recordUpdate', () => {
  const response = {
    id: 'recA',
    createdTime: '2026-03-12T10:00:00.000Z',
    fields: { Name: 'Paris Meetup', Seats: 90 },
  };

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue(response);
    vi.spyOn(__, 'formatRecord').mockReturnValue({ id: 'formatted' });
    vi.spyOn(__, 'recordParseContent').mockReturnValue({ Seats: 90 });
  });

  it('sends only the given Fields as a PATCH of the Record', async () => {
    await recordUpdate({
      recordId: 'recA',
      content: '{"Seats":90}',
      baseId: 'appDEVREL',
      tableId: 'My Meetups',
    });

    expect(__.callApi).toHaveBeenCalledWith('appDEVREL/My%20Meetups/recA', {
      method: 'PATCH',
      body: { fields: { Seats: 90 } },
    });
  });

  it('parses the content from the inline value and the data file', async () => {
    await recordUpdate({
      recordId: 'recA',
      content: '{"Seats":90}',
      dataFile: './changes.json',
      baseId: 'appDEVREL',
      tableId: 'tblMEETUPS',
    });

    expect(__.recordParseContent).toHaveBeenCalledWith({
      content: '{"Seats":90}',
      dataFile: './changes.json',
    });
  });

  it('returns the updated Record, formatted', async () => {
    const actual = await recordUpdate({
      recordId: 'recA',
      content: '{"Seats":90}',
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
      await recordUpdate({ content: '{}', ...options });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', code);
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('fails with AIRTABLE_CONTENT_INVALID before any call on invalid content', async () => {
    __.recordParseContent.mockImplementation(() => {
      throw firostError('AIRTABLE_CONTENT_INVALID', 'Invalid JSON');
    });

    let actual = null;
    try {
      await recordUpdate({
        recordId: 'recA',
        content: '{Seats:',
        baseId: 'appDEVREL',
        tableId: 'tblMEETUPS',
      });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_CONTENT_INVALID');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('surfaces the failure of the API', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('AIRTABLE_REQUEST_FAILED', 'NOT_FOUND');
    });

    let actual = null;
    try {
      await recordUpdate({
        recordId: 'recMISSING',
        content: '{"Seats":90}',
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
