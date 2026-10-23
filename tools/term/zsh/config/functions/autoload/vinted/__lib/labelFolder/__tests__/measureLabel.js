import path from 'node:path';
import { remove, tmpDirectory } from 'firost';
import { measureLabel } from '../measureLabel.js';
import { writeBinary } from '../writeBinary.js';
import { buildFakeLabel } from './helpers.js';

describe('measureLabel', () => {
  let testDirectory;
  beforeEach(() => {
    testDirectory = tmpDirectory('vinted/measureLabel');
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('returns the box around the printed area, in points from the bottom-left', async () => {
    const labelPath = path.join(testDirectory, 'label.pdf');
    await writeBinary(
      await buildFakeLabel({ x: 100, y: 50, width: 200, height: 300 }),
      labelPath,
    );

    const actual = await measureLabel(labelPath);

    // The box is padded by a few points and rounded to the render resolution
    expect(actual.left).toBeGreaterThanOrEqual(90);
    expect(actual.left).toBeLessThanOrEqual(100);
    expect(actual.right).toBeGreaterThanOrEqual(300);
    expect(actual.right).toBeLessThanOrEqual(310);
    expect(actual.top).toBeGreaterThanOrEqual(841.89 - 50);
    expect(actual.top).toBeLessThanOrEqual(841.89 - 40);
    expect(actual.bottom).toBeGreaterThanOrEqual(841.89 - 350 - 10);
    expect(actual.bottom).toBeLessThanOrEqual(841.89 - 350);
  });
});
