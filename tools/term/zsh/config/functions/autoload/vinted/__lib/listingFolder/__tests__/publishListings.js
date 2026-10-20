import path from 'node:path';
import { remove, tmpDirectory, write } from 'firost';
import { buildListing } from '../buildListing.js';
import { __, publishListings } from '../publishListings.js';
import { readTracking } from '../readTracking.js';
import { updateTracking } from '../updateTracking.js';

describe('publishListings', () => {
  const DRAFT_TRACKING = {
    status: 'draft',
    url: null,
    postedAt: null,
    soldAt: null,
    isPriceUncertain: false,
  };
  let testDirectory;

  /**
   * Build a listing folder under the test directory
   * @param {string} name - Folder name, relative to the test directory
   * @returns {Promise<string>} Path of the listing folder
   */
  async function addListing(name) {
    const folder = path.join(testDirectory, name);
    await write('', path.join(folder, 'front.jpg'));
    await buildListing(folder, { series: name, price: 4 });
    return folder;
  }

  /**
   * Make the post helper return a URL derived from the listing folder name
   */
  function mockPostSuccess() {
    vi.spyOn(__, 'postListing').mockImplementation((listingPath) => {
      const name = path.basename(path.dirname(listingPath));
      return `{"url":"https://www.vinted.fr/items/${name}"}`;
    });
  }

  beforeEach(() => {
    testDirectory = tmpDirectory('vinted/publishListings');
    vi.spyOn(__, 'sleep').mockReturnValue();
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  describe('tracking', () => {
    it('writes url, postedAt and status online after a publication', async () => {
      mockPostSuccess();
      const folder = await addListing('Dune');

      await publishListings(testDirectory, { pauseInMs: 0 });

      const actual = await readTracking(folder);
      expect(actual).toEqual({
        ...DRAFT_TRACKING,
        status: 'online',
        url: 'https://www.vinted.fr/items/Dune',
        postedAt: expect.stringMatching(/^\d{4}-\d{2}-\d{2}T/),
      });
    });

    it('posts the listings in order, with absolute paths', async () => {
      mockPostSuccess();
      await addListing('Dune');
      await addListing('Asterix');

      await publishListings(testDirectory, { pauseInMs: 0 });

      const actual = __.postListing.mock.calls.map(
        ([listingPath]) => listingPath,
      );
      expect(actual).toEqual([
        path.join(testDirectory, 'Asterix', 'listing.json'),
        path.join(testDirectory, 'Dune', 'listing.json'),
      ]);
    });

    it('skips a listing that already has a url', async () => {
      mockPostSuccess();
      const folder = await addListing('Dune');
      await updateTracking(folder, { url: 'https://www.vinted.fr/items/9' });

      await publishListings(testDirectory, { pauseInMs: 0 });

      expect(__.postListing).not.toHaveBeenCalled();
    });

    it('skips the online and sold listings', async () => {
      mockPostSuccess();
      const online = await addListing('Dune');
      await updateTracking(online, { status: 'online' });
      const sold = await addListing('Asterix');
      await updateTracking(sold, { status: 'sold' });

      await publishListings(testDirectory, { pauseInMs: 0 });

      expect(__.postListing).not.toHaveBeenCalled();
    });

    it('ignores the Misc folder', async () => {
      mockPostSuccess();
      await addListing('Misc/Unknown 1');

      await publishListings(testDirectory, { pauseInMs: 0 });

      expect(__.postListing).not.toHaveBeenCalled();
    });

    it('returns the published listings', async () => {
      mockPostSuccess();
      await addListing('Dune');

      const actual = await publishListings(testDirectory, { pauseInMs: 0 });

      expect(actual).toEqual([
        {
          folder: path.join(testDirectory, 'Dune'),
          url: 'https://www.vinted.fr/items/Dune',
        },
      ]);
    });
  });

  describe('pause', () => {
    it('pauses between two listings, not after the last one', async () => {
      mockPostSuccess();
      await addListing('Dune');
      await addListing('Asterix');
      await addListing('Tintin');

      await publishListings(testDirectory, { pauseInMs: 1500 });

      expect(__.sleep).toHaveBeenCalledTimes(2);
      expect(__.sleep).toHaveBeenCalledWith(1500);
    });
  });

  describe('failure', () => {
    /**
     * Make the post helper fail for one listing folder
     * @param {string} failingName - Folder name that fails
     */
    function mockPostFailure(failingName) {
      vi.spyOn(__, 'postListing').mockImplementation((listingPath) => {
        const name = path.basename(path.dirname(listingPath));
        if (name === failingName) {
          throw new Error('upload rejected');
        }
        return `{"url":"https://www.vinted.fr/items/${name}"}`;
      });
    }

    it('stops at the first failure and leaves later listings as drafts', async () => {
      mockPostFailure('Dune');
      await addListing('Asterix');
      await addListing('Dune');
      const later = await addListing('Tintin');

      try {
        await publishListings(testDirectory, { pauseInMs: 0 });
      } catch {
        // The failure is asserted in its own test
      }

      expect(__.postListing).toHaveBeenCalledTimes(2);
      expect(await readTracking(later)).toEqual(DRAFT_TRACKING);
    });

    it('keeps the listings published before the failure', async () => {
      mockPostFailure('Dune');
      const before = await addListing('Asterix');
      await addListing('Dune');

      try {
        await publishListings(testDirectory, { pauseInMs: 0 });
      } catch {
        // The failure is asserted in its own test
      }

      expect(await readTracking(before)).toEqual({
        ...DRAFT_TRACKING,
        status: 'online',
        url: 'https://www.vinted.fr/items/Asterix',
        postedAt: expect.any(String),
      });
    });

    it('leaves the failed listing as a draft', async () => {
      mockPostFailure('Dune');
      const failed = await addListing('Dune');

      try {
        await publishListings(testDirectory, { pauseInMs: 0 });
      } catch {
        // The failure is asserted in its own test
      }

      expect(await readTracking(failed)).toEqual(DRAFT_TRACKING);
    });

    it('leaves the listing as a draft when the output has no url', async () => {
      vi.spyOn(__, 'postListing').mockReturnValue('Screenshot saved');
      const folder = await addListing('Dune');

      try {
        await publishListings(testDirectory, { pauseInMs: 0 });
      } catch {
        // The failure is asserted in its own test
      }

      expect(await readTracking(folder)).toEqual(DRAFT_TRACKING);
    });

    it('throws a message naming the failed listing', async () => {
      mockPostFailure('Dune');
      await addListing('Dune');

      let actual = null;
      try {
        await publishListings(testDirectory, { pauseInMs: 0 });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'VINTED_LISTING_PUBLISH_FAILED');
      expect(actual).toHaveProperty(
        'message',
        `Publication stopped at ${path.join(testDirectory, 'Dune')}: upload rejected`,
      );
    });
  });
});
