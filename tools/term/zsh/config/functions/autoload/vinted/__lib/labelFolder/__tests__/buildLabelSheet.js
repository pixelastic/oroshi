import { PDFDocument } from 'pdf-lib';
import { __, buildLabelSheet } from '../buildLabelSheet.js';
import { TINY_JPEG, buildFakeLabel } from './helpers.js';

describe('buildLabelSheet', () => {
  let labelBytes;
  const box = { left: 20, right: 320, top: 800, bottom: 500 };

  beforeEach(async () => {
    labelBytes = await buildFakeLabel({
      x: 30,
      y: 40,
      width: 280,
      height: 280,
    });
    vi.spyOn(__, 'measureLabel').mockReturnValue(box);
    vi.spyOn(__, 'readPhoto').mockReturnValue(TINY_JPEG);
  });

  /**
   * Count the pages of the sheet built for a number of items
   * @param {number} count - Number of items
   * @param {object} [item] - Fields to set on every item
   * @returns {Promise<number>} Number of pages
   */
  async function countPages(count, item = {}) {
    const items = Array.from({ length: count }, (_, index) => ({
      title: `Item ${index} - Œuvre “complète” ☆`,
      photoPath: '/photo.jpg',
      ...item,
    }));
    const bytes = await buildLabelSheet({
      labelBytes,
      labelPath: '/l.pdf',
      items,
    });
    return (await PDFDocument.load(bytes)).getPageCount();
  }

  it.each([
    { title: 'keeps few items on one page', count: 1, expected: 1 },
    { title: 'keeps four items on one page', count: 4, expected: 1 },
    { title: 'moves a long list on a second page', count: 20, expected: 2 },
    { title: 'still builds a page without items', count: 0, expected: 1 },
  ])('$title', async ({ count, expected }) => {
    const actual = await countPages(count);

    expect(actual).toEqual(expected);
  });

  it('builds a page for an item without photo', async () => {
    const actual = await countPages(2, { photoPath: null });

    expect(actual).toEqual(1);
  });

  it('builds a page for an item whose photo cannot be read', async () => {
    __.readPhoto.mockImplementation(() => {
      throw new Error('unreadable');
    });

    const actual = await countPages(2);

    expect(actual).toEqual(1);
  });
});
