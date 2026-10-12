import { formatFolder } from '../formatFolder.js';

describe('formatFolder', () => {
  it('returns the Folder as the API gives it', () => {
    const folder = { id: 399262, name: 'metadata', parentId: null };

    const actual = formatFolder(folder);

    expect(actual).toEqual(folder);
  });
});
