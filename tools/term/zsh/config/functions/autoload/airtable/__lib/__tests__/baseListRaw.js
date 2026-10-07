import { __ as apiMock } from '../api.js';
import { airtableBaseListRaw } from '../baseListRaw.js';
import { __ as separatorsMock } from '../separators.js';

describe('airtableBaseListRaw', () => {
  beforeEach(() => {
    vi.stubEnv('AIRTABLE_TOKEN_READ', 'read-token-abc');
    vi.spyOn(separatorsMock, 'readIcons').mockReturnValue({
      'table-separator': '▮',
      'table-separator-secondary': '▯',
    });
    vi.spyOn(apiMock, 'fetch').mockReturnValue({
      ok: true,
      status: 200,
      json: () => ({
        bases: [
          { id: 'appDEVREL123', name: 'DevRel', permissionLevel: 'create' },
          { id: 'appOTHER456', name: 'Other Base', permissionLevel: 'read' },
        ],
      }),
    });
  });
  afterEach(() => {
    vi.unstubAllEnvs();
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
    apiMock.fetch.mockReturnValue({
      ok: true,
      status: 200,
      json: () => ({ bases }),
    });
    const actual = await airtableBaseListRaw();
    expect(actual).toEqual(expected);
  });

  it('reads the schema with the Read token', async () => {
    await airtableBaseListRaw();
    expect(apiMock.fetch).toHaveBeenCalledWith(
      'https://api.airtable.com/v0/meta/bases',
      {
        method: 'GET',
        headers: { Authorization: 'Bearer read-token-abc' },
      },
    );
  });
});
