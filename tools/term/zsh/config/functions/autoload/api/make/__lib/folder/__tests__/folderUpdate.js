import { __, folderUpdate } from '../folderUpdate.js';

describe('folderUpdate', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ scenarioFolder: { id: 7 } });
    vi.spyOn(__, 'formatFolder').mockReturnValue({ id: 'formatted' });
  });

  it('calls the endpoint of the folder id with PATCH', async () => {
    await folderUpdate({ folderId: 7, name: 'oroshi-test-b' });

    expect(__.callApi).toHaveBeenCalledWith('scenarios-folders/7', {
      method: 'PATCH',
      body: { name: 'oroshi-test-b' },
    });
  });

  it.each([
    {
      title: 'the name',
      input: { name: 'oroshi-test-b' },
      expected: { name: 'oroshi-test-b' },
    },
    {
      title: 'the parent folder',
      input: { parentFolderId: 12 },
      expected: { parentId: 12 },
    },
    {
      title: 'nothing',
      input: {},
      expected: {},
    },
  ])('sends only $title', async ({ input, expected }) => {
    await folderUpdate({ folderId: 7, ...input });

    const [, { body }] = __.callApi.mock.calls[0];
    expect(body).toEqual(expected);
  });

  it('returns the folder, formatted', async () => {
    const actual = await folderUpdate({ folderId: 7, name: 'oroshi-test-b' });

    expect(__.formatFolder).toHaveBeenCalledWith({ id: 7 });
    expect(actual).toEqual({ id: 'formatted' });
  });
});
