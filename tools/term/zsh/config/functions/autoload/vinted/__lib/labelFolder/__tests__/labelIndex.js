import path from 'node:path';
import { exists, remove, tmpDirectory } from 'firost';
import { readLabelIndex } from '../readLabelIndex.js';
import { updateLabelIndex } from '../updateLabelIndex.js';

describe('labelIndex', () => {
  let testDirectory;
  beforeEach(() => {
    testDirectory = tmpDirectory('vinted/labelIndex');
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('reads an empty index when the folder has none', async () => {
    const actual = await readLabelIndex(testDirectory);

    expect(actual).toEqual({});
  });

  it('merges new entries with the existing ones', async () => {
    await updateLabelIndex(testDirectory, {
      '1.pdf': { conversationId: 'a', itemIds: ['1'] },
    });
    await updateLabelIndex(testDirectory, {
      '2.pdf': { conversationId: 'b', itemIds: ['2', '3'] },
    });

    const actual = await readLabelIndex(testDirectory);

    expect(actual).toEqual({
      '1.pdf': { conversationId: 'a', itemIds: ['1'] },
      '2.pdf': { conversationId: 'b', itemIds: ['2', '3'] },
    });
  });

  it('overwrites an entry with the same label name', async () => {
    await updateLabelIndex(testDirectory, {
      '1.pdf': { conversationId: 'a', itemIds: ['1'] },
    });
    await updateLabelIndex(testDirectory, {
      '1.pdf': { conversationId: 'a', itemIds: ['1', '9'] },
    });

    const actual = await readLabelIndex(testDirectory);

    expect(actual).toEqual({
      '1.pdf': { conversationId: 'a', itemIds: ['1', '9'] },
    });
  });

  it('stores the index as index.json in the folder', async () => {
    await updateLabelIndex(testDirectory, {
      '1.pdf': { conversationId: 'a', itemIds: ['1'] },
    });

    const actual = path.join(testDirectory, 'index.json');

    expect(await exists(actual)).toEqual(true);
  });
});
