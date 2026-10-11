import { __, airtableBaseListRaw } from '../baseListRaw.js';
import { __ as separatorsMock } from '../separators.js';

describe('airtableBaseListRaw', () => {
  beforeEach(() => {
    vi.spyOn(separatorsMock, 'readIcons').mockReturnValue({
      'table-separator': '▮',
      'table-separator-secondary': '▯',
    });
    vi.spyOn(__, 'callApi').mockReturnValue({
      bases: [
        { id: 'appDEVREL123', name: 'DevRel', permissionLevel: 'create' },
        { id: 'appOTHER456', name: 'Other Base', permissionLevel: 'read' },
      ],
    });
  });

  it('prints the ID and the name of each Base', async () => {
    const actual = await airtableBaseListRaw();
    expect(actual).toEqual(['appDEVREL123▮DevRel', 'appOTHER456▮Other Base']);
  });

  it.each([
    {
      title: 'removes newlines and separators from the names',
      bases: [{ id: 'appA', name: 'Line one\nLine▮two' }],
      expected: ['appA▮Line one Linetwo'],
    },
    {
      title: 'prints nothing when no Base is accessible',
      bases: [],
      expected: [],
    },
  ])('$title', async ({ bases, expected }) => {
    __.callApi.mockReturnValue({ bases });
    const actual = await airtableBaseListRaw();
    expect(actual).toEqual(expected);
  });

  it('reads the schema of the Bases', async () => {
    await airtableBaseListRaw();
    expect(__.callApi).toHaveBeenCalledWith('meta/bases');
  });
});
