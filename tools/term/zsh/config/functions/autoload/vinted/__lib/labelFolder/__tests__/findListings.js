import path from 'node:path';
import { remove, tmpDirectory, write, writeJson } from 'firost';
import { findListings } from '../findListings.js';

describe('findListings', () => {
  let testDirectory;
  beforeEach(async () => {
    testDirectory = tmpDirectory('vinted/findListings');
    await writeJson(
      {
        title: 'Tarot de Marseille - Héron',
        photos: ['../Tarot de Marseille - Héron.jpg'],
        url: 'https://www.vinted.fr/items/10465088326',
      },
      path.join(
        testDirectory,
        'Divers/annonces/Tarot de Marseille - Héron.json',
      ),
    );
    await writeJson(
      {
        title: 'Not published yet',
        photos: ['../draft.jpg'],
      },
      path.join(testDirectory, 'Divers/annonces/Draft.json'),
    );
    await writeJson(
      { title: 'Other json', url: 'https://www.vinted.fr/items/1' },
      path.join(testDirectory, 'Divers/other/Other.json'),
    );
    await write(
      '',
      path.join(testDirectory, 'Divers/Tarot de Marseille - Héron.jpg'),
    );
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('indexes the published listings by item id', async () => {
    const actual = await findListings(testDirectory);

    expect(actual).toEqual({
      10465088326: {
        title: 'Tarot de Marseille - Héron',
        photoPath: path.join(
          testDirectory,
          'Divers/Tarot de Marseille - Héron.jpg',
        ),
      },
    });
  });

  it('sets no photo path when the photo is missing', async () => {
    await remove(
      path.join(testDirectory, 'Divers/Tarot de Marseille - Héron.jpg'),
    );

    const actual = await findListings(testDirectory);

    expect(actual).toEqual({
      10465088326: { title: 'Tarot de Marseille - Héron', photoPath: null },
    });
  });
});
