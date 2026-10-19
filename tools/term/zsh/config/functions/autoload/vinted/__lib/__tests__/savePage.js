import path from 'node:path';
import { exists, read, remove, tmpDirectory, write } from 'firost';
import { savePage } from '../savePage.js';

describe('savePage', () => {
  let testDirectory;
  let page;
  beforeEach(() => {
    testDirectory = tmpDirectory('vinted/savePage');
    page = {
      waitForLoadState: vi.fn(),
      waitForTimeout: vi.fn(),
      content: () => '<html>confirmation</html>',
      screenshot: ({ path: screenshotPath }) => write('png', screenshotPath),
    };
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('writes the HTML of the page and returns its path', async () => {
    const actual = await savePage(page, testDirectory, 'confirmation');

    expect(actual).toEqual(path.join(testDirectory, 'confirmation.html'));
    expect(await read(actual)).toEqual('<html>confirmation</html>');
  });

  it('writes a screenshot next to the HTML', async () => {
    await savePage(page, testDirectory, 'confirmation');

    const actual = await exists(path.join(testDirectory, 'confirmation.png'));
    expect(actual).toEqual(true);
  });
});
