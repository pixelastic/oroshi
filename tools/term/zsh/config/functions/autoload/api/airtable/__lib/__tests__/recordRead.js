import { __, airtableRecordRead } from '../recordRead.js';

describe('airtableRecordRead', () => {
  const record = {
    id: 'recABC',
    fields: { name: 'Paris Meetup', description: 'Line one\nLine two' },
  };

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ records: [record] });
  });

  const read = (options) =>
    airtableRecordRead({
      base: 'appDEVREL123',
      table: 'Meetups',
      record: 'recABC',
      ...options,
    });

  it('returns the fields of the Record', async () => {
    const actual = await read();
    expect(actual).toEqual(record.fields);
  });

  it.each([
    {
      title: 'filters on the Record ID, with every Field by default',
      options: {},
      expected: {
        filterByFormula: "RECORD_ID()='recABC'",
        fields: [],
      },
    },
    {
      title: 'restricts the request to the requested Fields',
      options: { fields: ['name', 'date'] },
      expected: {
        filterByFormula: "RECORD_ID()='recABC'",
        fields: ['name', 'date'],
      },
    },
  ])('$title', async ({ options, expected }) => {
    await read(options);
    expect(__.callApi).toHaveBeenCalledWith('appDEVREL123/Meetups', {
      query: expected,
    });
  });

  it('encodes the name of the Table', async () => {
    await read({ table: 'My Meetups' });
    expect(__.callApi).toHaveBeenCalledWith(
      'appDEVREL123/My%20Meetups',
      expect.anything(),
    );
  });

  it('throws "Record not found" when no Record matches', async () => {
    __.callApi.mockReturnValue({ records: [] });

    let actual = null;
    try {
      await read({ record: 'recNONE' });
    } catch (error) {
      actual = error;
    }
    expect(actual).toHaveProperty('message', 'Record not found');
  });
});
