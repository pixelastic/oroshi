import { firostError } from 'firost';
import { __, databaseRead } from '../databaseRead.js';

describe('databaseRead', () => {
  const databaseId = '3447be57-b8fa-80f1-96b0-f5a9c91044e0';
  const dataSourceId = '3447be57-b8fa-809d-8d4d-000b761c66c9';
  const database = {
    id: databaseId,
    title: [{ plain_text: 'Meetups' }],
    data_sources: [{ id: dataSourceId, name: 'Meetups' }],
  };
  const dataSource = {
    id: dataSourceId,
    properties: { Name: { id: 'title', name: 'Name', type: 'title' } },
  };

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockReturnValue(databaseId);
    vi.spyOn(__, 'callApi').mockImplementation((path) =>
      path.startsWith('data_sources/') ? dataSource : database,
    );
    vi.spyOn(__, 'formatDatabase').mockReturnValue({ id: 'formatted' });
  });

  it('returns the Database with the properties of its data source, formatted', async () => {
    const actual = await databaseRead({ databaseId });

    expect(__.formatDatabase).toHaveBeenCalledWith({
      ...database,
      properties: dataSource.properties,
    });
    expect(actual).toEqual({ id: 'formatted' });
  });

  it('resolves the data source before reading the schema', async () => {
    await databaseRead({ databaseId });

    expect(__).toHaveProperty('callApi.mock.calls', [
      [`databases/${databaseId}`],
      [`data_sources/${dataSourceId}`],
    ]);
  });

  it('accepts a URL as the Database id', async () => {
    const url = `https://www.notion.so/workspace/Meetups-${databaseId.replaceAll('-', '')}?v=abc`;

    await databaseRead({ databaseId: url });

    expect(__.parseId).toHaveBeenCalledWith(url);
    expect(__.callApi).toHaveBeenCalledWith(`databases/${databaseId}`);
  });

  it('throws when the Database id is invalid', async () => {
    __.parseId.mockImplementation(() => {
      throw firostError('NOTION_ID_INVALID', 'No Notion id found');
    });

    let actual = null;
    try {
      await databaseRead({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'NOTION_ID_INVALID');
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
