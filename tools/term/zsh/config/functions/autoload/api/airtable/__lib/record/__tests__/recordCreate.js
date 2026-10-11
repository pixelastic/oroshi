import { firostError } from 'firost';
import { __, recordCreate } from '../recordCreate.js';

describe('recordCreate', () => {
  const response = {
    id: 'recNEW',
    createdTime: '2026-03-12T10:00:00.000Z',
    fields: { Name: 'Paris Meetup' },
  };

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue(response);
    vi.spyOn(__, 'formatRecord').mockReturnValue({ id: 'formatted' });
    vi.spyOn(__, 'recordParseContent').mockReturnValue({
      Name: 'Paris Meetup',
    });
  });

  it('sends the content as the Fields of a POST', async () => {
    await recordCreate({
      content: '{"Name":"Paris Meetup"}',
      baseId: 'appDEVREL',
      tableId: 'My Meetups',
    });

    expect(__.callApi).toHaveBeenCalledWith('appDEVREL/My%20Meetups', {
      method: 'POST',
      body: { fields: { Name: 'Paris Meetup' } },
    });
  });

  it('parses the content from the inline value and the data file', async () => {
    await recordCreate({
      content: '{"Name":"Paris Meetup"}',
      dataFile: './record.json',
      baseId: 'appDEVREL',
      tableId: 'tblMEETUPS',
    });

    expect(__.recordParseContent).toHaveBeenCalledWith({
      content: '{"Name":"Paris Meetup"}',
      dataFile: './record.json',
    });
  });

  it('returns the created Record, formatted', async () => {
    const actual = await recordCreate({
      content: '{"Name":"Paris Meetup"}',
      baseId: 'appDEVREL',
      tableId: 'tblMEETUPS',
    });

    expect(__.formatRecord).toHaveBeenCalledWith(response);
    expect(actual).toEqual({ id: 'formatted' });
  });

  it.each([
    {
      title: 'Base',
      options: { tableId: 'tblA' },
      code: 'AIRTABLE_BASE_ID_MISSING',
    },
    {
      title: 'Table',
      options: { baseId: 'appA' },
      code: 'AIRTABLE_TABLE_ID_MISSING',
    },
  ])('throws when the $title is missing', async ({ options, code }) => {
    let actual = null;
    try {
      await recordCreate({ content: '{}', ...options });
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
      await recordCreate({
        content: '{Name:',
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
      throw firostError('AIRTABLE_REQUEST_FAILED', 'UNKNOWN_FIELD_NAME');
    });

    let actual = null;
    try {
      await recordCreate({
        content: '{"Nope":1}',
        baseId: 'appDEVREL',
        tableId: 'tblMEETUPS',
      });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', 'UNKNOWN_FIELD_NAME');
  });
});
