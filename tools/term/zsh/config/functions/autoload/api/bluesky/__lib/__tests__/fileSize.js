import { remove, tmpDirectory, write } from 'firost';
import { fileSize } from '../fileSize.js';

describe('fileSize', () => {
  let testDirectory;
  beforeEach(() => {
    testDirectory = tmpDirectory('bluesky/fileSize');
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('returns the size of the file in bytes', async () => {
    const filepath = `${testDirectory}/a.txt`;
    await write('héllo', filepath);

    const actual = await fileSize(filepath);

    expect(actual).toEqual(6);
  });

  it('returns null when the file does not exist', async () => {
    const actual = await fileSize(`${testDirectory}/missing.png`);

    expect(actual).toEqual(null);
  });
});
