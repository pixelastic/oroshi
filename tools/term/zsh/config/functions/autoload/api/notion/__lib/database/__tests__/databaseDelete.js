import { __, databaseDelete } from '../databaseDelete.js';

describe('databaseDelete', () => {
  const databaseId = '11111111-1111-1111-1111-111111111111';

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockReturnValue(databaseId);
    vi.spyOn(__, 'callApi').mockReturnValue({ id: databaseId });
  });

  it('puts the Database in the Trash', async () => {
    await databaseDelete({ databaseId });

    expect(__.callApi).toHaveBeenCalledWith(`databases/${databaseId}`, {
      method: 'PATCH',
      body: { in_trash: true },
    });
  });

  it('returns the id of the Database', async () => {
    const actual = await databaseDelete({ databaseId });

    expect(actual).toEqual(databaseId);
  });

  it('accepts a URL as the Database id', async () => {
    const url = `https://www.notion.so/Meetups-${databaseId.replaceAll('-', '')}`;

    await databaseDelete({ databaseId: url });

    expect(__.parseId).toHaveBeenCalledWith(url);
  });
});
