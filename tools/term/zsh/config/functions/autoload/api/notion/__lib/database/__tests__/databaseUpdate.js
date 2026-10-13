import { __, databaseUpdate } from '../databaseUpdate.js';

describe('databaseUpdate', () => {
  const databaseId = '11111111-1111-1111-1111-111111111111';
  const dataSourceId = '22222222-2222-2222-2222-222222222222';
  const database = { id: databaseId, data_sources: [{ id: dataSourceId }] };
  const properties = { Status: { select: { options: [{ name: 'Done' }] } } };
  const formatted = { id: databaseId, url: 'u', title: 'Meetups' };

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockImplementation((input) => input);
    vi.spyOn(__, 'getJsonFromOptions').mockReturnValue({ properties });
    vi.spyOn(__, 'callApi').mockReturnValue(database);
    vi.spyOn(__, 'resolveDataSource').mockReturnValue({ id: dataSourceId });
    vi.spyOn(__, 'databaseRead').mockReturnValue(formatted);
  });

  it('sends the property changes to the data source of the Database', async () => {
    await databaseUpdate({ databaseId, data: '{}' });

    expect(__.callApi).toHaveBeenCalledWith(`databases/${databaseId}`);
    expect(__.resolveDataSource).toHaveBeenCalledWith(database);
    expect(__.callApi).toHaveBeenCalledWith(`data_sources/${dataSourceId}`, {
      method: 'PATCH',
      body: { properties },
    });
  });

  it('sends the new title to the Database', async () => {
    __.getJsonFromOptions.mockReturnValue({ title: 'Events' });

    await databaseUpdate({ databaseId, data: '{}' });

    expect(__.callApi).toHaveBeenCalledWith(`databases/${databaseId}`, {
      method: 'PATCH',
      body: { title: [{ type: 'text', text: { content: 'Events' } }] },
    });
    expect(__.callApi).not.toHaveBeenCalledWith(
      `data_sources/${dataSourceId}`,
      expect.anything(),
    );
  });

  it('reads the changes from the data and the data file', async () => {
    await databaseUpdate({ databaseId, data: '{"a":1}', dataFile: './a.json' });

    expect(__.getJsonFromOptions).toHaveBeenCalledWith(
      { databaseId, data: '{"a":1}', dataFile: './a.json' },
      'data',
      {},
    );
  });

  it('accepts a URL as the Database id', async () => {
    const url = `https://www.notion.so/Meetups-${databaseId.replaceAll('-', '')}`;
    __.parseId.mockReturnValue(databaseId);

    await databaseUpdate({ databaseId: url });

    expect(__.parseId).toHaveBeenCalledWith(url);
    expect(__.callApi).toHaveBeenCalledWith(`databases/${databaseId}`);
  });

  it('returns the updated Database, as read', async () => {
    const actual = await databaseUpdate({ databaseId });

    expect(__.databaseRead).toHaveBeenCalledWith({ databaseId });
    expect(actual).toEqual(formatted);
  });
});
