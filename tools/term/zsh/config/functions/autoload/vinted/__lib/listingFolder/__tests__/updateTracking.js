import path from 'node:path';
import { readJson, remove, tmpDirectory, write } from 'firost';
import { buildListing } from '../buildListing.js';
import { readTracking } from '../readTracking.js';
import { updateTracking } from '../updateTracking.js';

describe('updateTracking', () => {
  let testDirectory;
  let filepath;

  beforeEach(async () => {
    testDirectory = tmpDirectory('vinted/updateTracking');
    await write('', path.join(testDirectory, 'front.jpg'));
    filepath = await buildListing(testDirectory, {
      series: 'Dune',
      number: 2,
      publisher: 'Pocket',
      isbn: '',
      price: 4,
    });
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('updates the tracking fields', async () => {
    await updateTracking(testDirectory, {
      status: 'online',
      url: 'https://www.vinted.fr/items/123',
      postedAt: '2026-10-20T10:00:00.000Z',
    });

    const actual = await readTracking(testDirectory);

    expect(actual).toEqual({
      status: 'online',
      url: 'https://www.vinted.fr/items/123',
      postedAt: '2026-10-20T10:00:00.000Z',
      soldAt: null,
      isPriceUncertain: false,
    });
  });

  it('does not touch the other fields', async () => {
    const before = await readJson(filepath);

    await updateTracking(testDirectory, { status: 'sold', soldAt: 'x' });

    const actual = await readJson(filepath);
    expect(actual).toEqual({ ...before, status: 'sold', soldAt: 'x' });
  });

  it('ignores fields that are not tracking fields', async () => {
    const before = await readJson(filepath);

    await updateTracking(testDirectory, { price: 99 });

    const actual = await readJson(filepath);
    expect(actual).toEqual(before);
  });

  it('rejects an unknown status', async () => {
    let actual = null;
    try {
      await updateTracking(testDirectory, { status: 'lost' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'VINTED_LISTING_STATUS_INVALID');
  });
});
