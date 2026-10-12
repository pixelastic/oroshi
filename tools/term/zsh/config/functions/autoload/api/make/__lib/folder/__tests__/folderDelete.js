import { __, folderDelete } from '../folderDelete.js';

describe('folderDelete', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ scenarioFolder: 7 });
    vi.spyOn(__, 'folderRead').mockReturnValue({
      id: 7,
      subfolders: [],
      scenarios: [],
    });
  });

  it('calls the endpoint of the folder id with DELETE when the folder is empty', async () => {
    await folderDelete({ folderId: 7 });

    expect(__.folderRead).toHaveBeenCalledWith({ folderId: 7 });
    expect(__.callApi).toHaveBeenCalledWith('scenarios-folders/7', {
      method: 'DELETE',
    });
  });

  it('returns the id when the folder is empty', async () => {
    const actual = await folderDelete({ folderId: 7 });

    expect(actual).toEqual(7);
  });

  it.each([
    {
      title: 'a subfolder',
      input: { subfolders: [{ id: 8 }], scenarios: [] },
    },
    {
      title: 'a direct scenario',
      input: { subfolders: [], scenarios: [{ id: 100 }] },
    },
  ])(
    'throws MAKE_FOLDER_NOT_EMPTY when the folder has $title',
    async ({ input }) => {
      __.folderRead.mockReturnValue({ id: 7, ...input });

      let actual = null;
      try {
        await folderDelete({ folderId: 7 });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'MAKE_FOLDER_NOT_EMPTY');
    },
  );

  it('does not call DELETE when it refuses', async () => {
    __.folderRead.mockReturnValue({
      id: 7,
      subfolders: [{ id: 8 }],
      scenarios: [],
    });

    try {
      await folderDelete({ folderId: 7 });
    } catch {
      // The refusal is checked by the previous test
    }

    expect(__.callApi).not.toHaveBeenCalled();
  });
});
