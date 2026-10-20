import path from 'node:path';
import { remove, tmpDirectory, write } from 'firost';
import { buildListing } from '../buildListing.js';
import { recapListings } from '../recapListings.js';
import { updateTracking } from '../updateTracking.js';

describe('recapListings', () => {
  let testDirectory;

  /**
   * Build a listing folder under the test directory
   * @param {string} name - Folder name, relative to the test directory
   * @param {object} identification - Identification data of the listing
   * @returns {Promise<string>} Path of the listing folder
   */
  async function addListing(name, identification) {
    const folder = path.join(testDirectory, name);
    await write('', path.join(folder, 'front.jpg'));
    await buildListing(folder, { series: name, ...identification });
    return folder;
  }

  beforeEach(() => {
    testDirectory = tmpDirectory('vinted/recapListings');
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  describe('totals', () => {
    it('sums the asked prices of the listings', async () => {
      await addListing('Dune', { price: 4 });
      await addListing('Asterix', { price: 2.5 });

      const actual = await recapListings(testDirectory);

      expect(actual).toEqual(expect.objectContaining({ count: 2, total: 6.5 }));
    });

    it('counts only the draft listings', async () => {
      await addListing('Dune', { price: 4 });
      const online = await addListing('Asterix', { price: 3 });
      await updateTracking(online, { status: 'online' });
      const sold = await addListing('Tintin', { price: 5 });
      await updateTracking(sold, { status: 'sold' });

      const actual = await recapListings(testDirectory);

      expect(actual).toEqual(expect.objectContaining({ count: 1, total: 4 }));
    });

    it('ignores the Misc folder', async () => {
      await addListing('Dune', { price: 4 });
      await addListing('Misc/Unknown 1', { price: 9 });

      const actual = await recapListings(testDirectory);

      expect(actual).toEqual(expect.objectContaining({ count: 1, total: 4 }));
    });

    it('reports nothing for a root with no listing', async () => {
      const actual = await recapListings(testDirectory);

      expect(actual).toEqual({ count: 0, total: 0, uncertain: [] });
    });
  });

  describe('uncertain prices', () => {
    it('lists the title and price of the uncertain listings', async () => {
      await addListing('Dune', { price: 4, isPriceUncertain: true });
      await addListing('Asterix', { price: 3 });

      const actual = await recapListings(testDirectory);

      expect(actual).toHaveProperty('uncertain', [{ title: 'Dune', price: 4 }]);
    });
  });
});
