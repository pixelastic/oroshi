import path from 'node:path';
import { remove, tmpDirectory, write } from 'firost';
import { buildListing } from '../buildListing.js';
import { readTracking } from '../readTracking.js';
import { syncSales } from '../syncSales.js';
import { updateTracking } from '../updateTracking.js';

describe('syncSales', () => {
  const now = new Date('2026-10-22T12:00:00.000Z');
  let testDirectory;
  let folders;

  /**
   * Build an online listing folder under the test directory
   * @param {string} name - Folder name, relative to the test directory
   * @param {object} tracking - Tracking fields to set
   * @returns {Promise<string>} Path of the listing folder
   */
  async function addListing(name, tracking) {
    const folder = path.join(testDirectory, name);
    await write('', path.join(folder, 'front.jpg'));
    await buildListing(folder, { series: name, price: 4 });
    await updateTracking(folder, { status: 'online', ...tracking });
    return folder;
  }

  beforeEach(async () => {
    testDirectory = tmpDirectory('vinted/syncSales');
    folders = {
      dune: await addListing('Dune', {
        url: 'https://www.vinted.fr/items/123-dune',
      }),
      asterix: await addListing('Asterix', {
        url: 'https://www.vinted.fr/items/456-asterix',
      }),
      tintin: await addListing('Tintin', {
        url: 'https://www.vinted.fr/items/789-tintin',
        status: 'sold',
        soldAt: '2026-10-01T10:00:00.000Z',
      }),
      misc: await addListing('Misc/Unknown 1', {
        url: 'https://www.vinted.fr/items/123-dune',
      }),
    };
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('marks the listing whose url holds a sold id', async () => {
    await syncSales(testDirectory, ['123'], { now });

    const actual = await readTracking(folders.dune);

    expect(actual).toEqual(
      expect.objectContaining({
        status: 'sold',
        soldAt: '2026-10-22T12:00:00.000Z',
      }),
    );
  });

  it.each([
    {
      title: 'leaves the other listings untouched',
      soldIds: ['123'],
      key: 'asterix',
      expected: { status: 'online', soldAt: null },
    },
    {
      title: 'does not match on a partial id',
      soldIds: ['12', '3', '1234'],
      key: 'dune',
      expected: { status: 'online', soldAt: null },
    },
    {
      title: 'keeps the soldAt of a listing already sold',
      soldIds: ['789'],
      key: 'tintin',
      expected: { status: 'sold', soldAt: '2026-10-01T10:00:00.000Z' },
    },
    {
      title: 'ignores the Misc folder',
      soldIds: ['123'],
      key: 'misc',
      expected: { status: 'online', soldAt: null },
    },
  ])('$title', async ({ soldIds, key, expected }) => {
    await syncSales(testDirectory, soldIds, { now });

    const actual = await readTracking(folders[key]);

    expect(actual).toEqual(expect.objectContaining(expected));
  });

  it('returns the folders it marked', async () => {
    const actual = await syncSales(testDirectory, ['123', '789'], { now });

    expect(actual).toEqual([folders.dune]);
  });
});
