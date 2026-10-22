import path from 'node:path';
import { remove, tmpDirectory, write } from 'firost';
import { buildListing } from '../buildListing.js';
import { listStaleListings } from '../listStaleListings.js';
import { updateTracking } from '../updateTracking.js';

describe('listStaleListings', () => {
  const now = new Date('2026-10-22T12:00:00.000Z');
  let testDirectory;

  /**
   * Build a listing folder under the test directory
   * @param {string} name - Folder name, relative to the test directory
   * @param {object} tracking - Tracking fields to set
   * @returns {Promise<string>} Path of the listing folder
   */
  async function addListing(name, tracking) {
    const folder = path.join(testDirectory, name);
    await write('', path.join(folder, 'front.jpg'));
    await buildListing(folder, { series: name, price: 4 });
    await updateTracking(folder, tracking);
    return folder;
  }

  beforeEach(async () => {
    testDirectory = tmpDirectory('vinted/listStaleListings');
    await addListing('Old', {
      status: 'online',
      postedAt: '2026-09-01T12:00:00.000Z',
    });
    await addListing('Recent', {
      status: 'online',
      postedAt: '2026-10-20T12:00:00.000Z',
    });
    await addListing('Exactly 30', {
      status: 'online',
      postedAt: '2026-09-22T12:00:00.000Z',
    });
    await addListing('Old sold', {
      status: 'sold',
      postedAt: '2026-09-01T12:00:00.000Z',
    });
    await addListing('Old draft', { status: 'draft' });
    await addListing('Misc/Unknown 1', {
      status: 'online',
      postedAt: '2026-09-01T12:00:00.000Z',
    });
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it.each([
    {
      title: 'more than 30 days',
      days: 30,
      expected: ['Old'],
    },
    {
      title: 'more than 1 day',
      days: 1,
      expected: ['Exactly 30', 'Old', 'Recent'],
    },
  ])('lists the listings online for $title', async ({ days, expected }) => {
    const stale = await listStaleListings(testDirectory, { days, now });

    const actual = stale.map(({ folder }) => path.basename(folder));

    expect(actual).toEqual(expected);
  });

  it('reads the title, url and age of a listing', async () => {
    const actual = await listStaleListings(testDirectory, { days: 30, now });

    expect(actual).toEqual([
      {
        folder: path.join(testDirectory, 'Old'),
        title: expect.stringContaining('Old'),
        url: null,
        ageInDays: 51,
      },
    ]);
  });
});
