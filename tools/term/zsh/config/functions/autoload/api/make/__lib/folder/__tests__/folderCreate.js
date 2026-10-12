import { __, folderCreate } from '../folderCreate.js';

describe('folderCreate', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({
      key: 'secret-key',
      teamId: '42',
      zone: 'eu2',
    });
    vi.spyOn(__, 'callApi').mockReturnValue({ scenarioFolder: { id: 7 } });
    vi.spyOn(__, 'formatFolder').mockReturnValue({ id: 'formatted' });
  });

  it('sends the team, the name and the parent folder', async () => {
    await folderCreate({ name: 'oroshi-test-a', parentFolderId: 12 });

    expect(__.callApi).toHaveBeenCalledWith('scenarios-folders', {
      method: 'POST',
      body: { teamId: 42, name: 'oroshi-test-a', parentId: 12 },
    });
  });

  it('omits the parent folder when it is not given', async () => {
    await folderCreate({ name: 'oroshi-test-a' });

    const [, { body }] = __.callApi.mock.calls[0];
    expect(body).toEqual({ teamId: 42, name: 'oroshi-test-a' });
  });

  it('returns the created folder, formatted', async () => {
    const actual = await folderCreate({ name: 'oroshi-test-a' });

    expect(__.formatFolder).toHaveBeenCalledWith({ id: 7 });
    expect(actual).toEqual({ id: 'formatted' });
  });
});
