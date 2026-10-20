import path from 'node:path';
import { remove, tmpDirectory, write } from 'firost';
import { buildListing } from '../buildListing.js';
import { readTracking } from '../readTracking.js';

describe('readTracking', () => {
  let testDirectory;

  beforeEach(async () => {
    testDirectory = tmpDirectory('vinted/readTracking');
    await write('', path.join(testDirectory, 'front.jpg'));
    await buildListing(testDirectory, {
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

  it('reads the tracking fields of a folder written earlier', async () => {
    const actual = await readTracking(testDirectory);

    expect(actual).toEqual({
      status: 'draft',
      url: null,
      postedAt: null,
      soldAt: null,
    });
  });
});
