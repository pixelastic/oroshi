import path from 'node:path';
import { exists, remove, tmpDirectory, writeJson } from 'firost';
import { PDFDocument } from 'pdf-lib';
import { buildLabelSheets } from '../buildLabelSheets.js';
import { writeBinary } from '../writeBinary.js';
import { buildFakeLabel } from './helpers.js';

describe('buildLabelSheets', () => {
  let testDirectory;
  let labelsDirectory;
  let outputDirectory;
  let listingsRoot;

  beforeEach(async () => {
    testDirectory = tmpDirectory('vinted/buildLabelSheets');
    labelsDirectory = path.join(testDirectory, 'labels');
    outputDirectory = path.join(testDirectory, 'sheets');
    listingsRoot = path.join(testDirectory, 'listings');

    const label = await buildFakeLabel({
      x: 30,
      y: 40,
      width: 280,
      height: 280,
    });
    await writeBinary(label, path.join(labelsDirectory, '1.pdf'));
    await writeBinary(label, path.join(labelsDirectory, '3.pdf'));
    await writeBinary(label, path.join(labelsDirectory, 'orphan.pdf'));
    await writeJson(
      {
        '1.pdf': {
          conversationId: 'a',
          items: [
            { id: '1', title: 'Inbox title one' },
            { id: '2', title: 'Inbox title two' },
          ],
        },
        '3.pdf': { conversationId: 'b', items: [{ id: '3', title: 'Three' }] },
        '4.pdf': { conversationId: 'c', items: [{ id: '4', title: 'Four' }] },
      },
      path.join(labelsDirectory, 'index.json'),
    );
    await writeJson(
      {
        title: 'One',
        photos: ['../one.jpg'],
        url: 'https://www.vinted.fr/items/1',
      },
      path.join(listingsRoot, 'Books/annonces/One.json'),
    );
    await writeJson(
      { title: 'Three', photos: [], url: 'https://www.vinted.fr/items/3' },
      path.join(listingsRoot, 'Books/annonces/Three.json'),
    );
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('writes one sheet per indexed label', async () => {
    await buildLabelSheets({ labelsDirectory, listingsRoot, outputDirectory });

    const actual = await Promise.all([
      exists(path.join(outputDirectory, '1.pdf')),
      exists(path.join(outputDirectory, '3.pdf')),
      exists(path.join(outputDirectory, '4.pdf')),
      exists(path.join(outputDirectory, 'orphan.pdf')),
    ]);

    expect(actual).toEqual([true, true, false, false]);
  });

  it('reports what is missing', async () => {
    const actual = await buildLabelSheets({
      labelsDirectory,
      listingsRoot,
      outputDirectory,
    });

    expect(actual).toEqual({
      written: ['1.pdf', '3.pdf'],
      skipped: [],
      withoutListing: [{ label: '1.pdf', itemIds: ['2'] }],
      withoutIndex: ['orphan.pdf'],
      withoutLabel: ['4.pdf'],
    });
  });

  it('skips the labels that already have a sheet', async () => {
    await buildLabelSheets({ labelsDirectory, listingsRoot, outputDirectory });
    await remove(path.join(outputDirectory, '3.pdf'));

    const actual = await buildLabelSheets({
      labelsDirectory,
      listingsRoot,
      outputDirectory,
    });

    expect(actual).toMatchObject({ written: ['3.pdf'], skipped: ['1.pdf'] });
  });

  it('rebuilds every sheet when overwrite is set', async () => {
    await buildLabelSheets({ labelsDirectory, listingsRoot, outputDirectory });

    const actual = await buildLabelSheets({
      labelsDirectory,
      listingsRoot,
      outputDirectory,
      overwrite: true,
    });

    expect(actual).toMatchObject({ written: ['1.pdf', '3.pdf'], skipped: [] });
  });

  it('keeps the label page and adds the list', async () => {
    await buildLabelSheets({ labelsDirectory, listingsRoot, outputDirectory });

    const bytes = await (
      await import('node:fs/promises')
    ).readFile(path.join(outputDirectory, '1.pdf'));
    const actual = (await PDFDocument.load(bytes)).getPageCount();

    expect(actual).toEqual(1);
  });
});
