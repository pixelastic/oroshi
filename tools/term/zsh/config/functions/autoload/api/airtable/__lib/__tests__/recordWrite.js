import { __, airtableRecordWrite } from '../recordWrite.js';

describe('airtableRecordWrite', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 'recNEW', fields: {} });
  });

  it('creates a Record and returns its ID', async () => {
    const actual = await airtableRecordWrite({
      base: 'appDEVREL123',
      table: 'Meetups',
      fields: { name: 'Paris Meetup', attendees: 42 },
    });

    expect(actual).toEqual('recNEW');
    expect(__.callApi).toHaveBeenCalledWith('appDEVREL123/Meetups', {
      method: 'POST',
      body: { fields: { name: 'Paris Meetup', attendees: 42 } },
    });
  });

  it('updates the given Record and returns its ID', async () => {
    __.callApi.mockReturnValue({ id: 'recABC', fields: {} });

    const actual = await airtableRecordWrite({
      base: 'appDEVREL123',
      table: 'Meetups',
      record: 'recABC',
      fields: { name: 'Paris Meetup' },
    });

    expect(actual).toEqual('recABC');
    expect(__.callApi).toHaveBeenCalledWith('appDEVREL123/Meetups/recABC', {
      method: 'PATCH',
      body: { fields: { name: 'Paris Meetup' } },
    });
  });

  it('encodes the name of the Table', async () => {
    await airtableRecordWrite({
      base: 'appDEVREL123',
      table: 'My Meetups',
      fields: {},
    });

    expect(__.callApi).toHaveBeenCalledWith(
      'appDEVREL123/My%20Meetups',
      expect.anything(),
    );
  });
});
