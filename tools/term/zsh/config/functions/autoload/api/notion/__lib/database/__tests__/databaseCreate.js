import { __, databaseCreate } from '../databaseCreate.js';

describe('databaseCreate', () => {
  const parentPageId = '11111111-1111-1111-1111-111111111111';
  const newDatabaseId = '22222222-2222-2222-2222-222222222222';
  const properties = { Name: { title: {} } };
  const schema = { title: 'Meetups', properties };
  const formatted = { id: newDatabaseId, url: 'u', title: 'Meetups' };

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockImplementation((input) => input);
    vi.spyOn(__, 'getJsonFromOptions').mockReturnValue(schema);
    vi.spyOn(__, 'callApi').mockReturnValue({ id: newDatabaseId });
    vi.spyOn(__, 'databaseRead').mockReturnValue(formatted);
  });

  it('creates a Database under a parent Page, with a title and properties', async () => {
    await databaseCreate({ parentPageId, data: '{}' });

    expect(__.callApi).toHaveBeenCalledWith('databases', {
      method: 'POST',
      body: {
        parent: { type: 'page_id', page_id: parentPageId },
        title: [{ type: 'text', text: { content: 'Meetups' } }],
        initial_data_source: { properties },
      },
    });
  });

  it('throws NOTION_PARENT_MISSING when --parentPageId is missing', async () => {
    let actual = null;
    try {
      await databaseCreate({ data: '{}' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'NOTION_PARENT_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('reads the schema from the data and the data file', async () => {
    await databaseCreate({
      parentPageId,
      data: '{"a":1}',
      dataFile: './a.json',
    });

    expect(__.getJsonFromOptions).toHaveBeenCalledWith(
      { parentPageId, data: '{"a":1}', dataFile: './a.json' },
      'data',
      {},
    );
  });

  it('accepts a URL as the parent Page', async () => {
    __.parseId.mockImplementation((input) => input.replace('https://x/', ''));

    await databaseCreate({ parentPageId: `https://x/${parentPageId}` });

    expect(__).toHaveProperty(
      'callApi.mock.calls.0.1.body.parent.page_id',
      parentPageId,
    );
  });

  it('returns the new Database, as read', async () => {
    const actual = await databaseCreate({ parentPageId });

    expect(__.databaseRead).toHaveBeenCalledWith({ databaseId: newDatabaseId });
    expect(actual).toEqual(formatted);
  });
});
