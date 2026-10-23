import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { _ } from 'golgoth';
import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';
import { measureLabel } from './measureLabel.js';

const run = promisify(execFile);

const PAGE_SIZE = [595.28, 841.89];
const MARGIN = 28;
const GAP = 22;
const ROW_HEIGHT = 46;
const THUMBNAIL_SIZE = 40;
const CHECKBOX_SIZE = 12;
const FONT_SIZE = 10;
const LINE_HEIGHT = 12;
const MAX_LINES = 3;
const PHOTO_LONGEST_SIDE = 200;
const GREY = rgb(0.45, 0.45, 0.45);

export let __;

/**
 * Build the sheet to print for a parcel: the label at its real size, then the
 * list of the items to put in the box
 * The list fills the blank part of the page under the label, and continues on
 * a second page when it does not fit.
 * @param {object} input - Input
 * @param {Uint8Array} input.labelBytes - Content of the label PDF
 * @param {string} input.labelPath - Path of the label PDF, used to measure it
 * @param {object[]} input.items - Items as { title, photoPath }. photoPath is
 * null when there is no photo
 * @returns {Promise<Uint8Array>} The sheet, as PDF bytes
 */
export async function buildLabelSheet({ labelBytes, labelPath, items }) {
  const document = await PDFDocument.create();
  const font = await document.embedFont(StandardFonts.Helvetica);
  const boldFont = await document.embedFont(StandardFonts.HelveticaBold);
  let page = document.addPage(PAGE_SIZE);
  const [pageWidth, pageHeight] = PAGE_SIZE;

  // The label, cropped to its printed area and never scaled up
  const labelDocument = await PDFDocument.load(labelBytes);
  const [embeddedLabel] = await document.embedPages(
    [labelDocument.getPage(0)],
    [await __.measureLabel(labelPath)],
  );
  const maxLabelHeight = pageHeight - 2 * MARGIN - 120;
  const scale = Math.min(
    1,
    (pageWidth - 2 * MARGIN) / embeddedLabel.width,
    maxLabelHeight / embeddedLabel.height,
  );
  const labelWidth = embeddedLabel.width * scale;
  const labelHeight = embeddedLabel.height * scale;
  page.drawPage(embeddedLabel, {
    x: MARGIN,
    y: pageHeight - MARGIN - labelHeight,
    width: labelWidth,
    height: labelHeight,
  });

  // A dashed line separates the label from the list
  let cursor = pageHeight - MARGIN - labelHeight - GAP / 2;
  page.drawLine({
    start: { x: MARGIN, y: cursor },
    end: { x: pageWidth - MARGIN, y: cursor },
    thickness: 0.6,
    color: GREY,
    dashArray: [4, 3],
  });

  cursor -= GAP;
  const count = items.length;
  page.drawText(
    __.printable(
      boldFont,
      `À mettre dans le colis : ${count} article${count > 1 ? 's' : ''}`,
    ),
    { x: MARGIN, y: cursor, size: 13, font: boldFont },
  );
  cursor -= 10;

  await _.reduce(
    items,
    async (previous, item) => {
      await previous;
      if (cursor - ROW_HEIGHT < MARGIN) {
        page = document.addPage(PAGE_SIZE);
        cursor = pageHeight - MARGIN;
      }
      const top = cursor;
      cursor -= ROW_HEIGHT;

      // A box to tick once the item is in the parcel
      page.drawRectangle({
        x: MARGIN,
        y: top - ROW_HEIGHT / 2 - CHECKBOX_SIZE / 2,
        width: CHECKBOX_SIZE,
        height: CHECKBOX_SIZE,
        borderColor: GREY,
        borderWidth: 1,
      });

      const photoX = MARGIN + CHECKBOX_SIZE + 10;
      await __.drawPhoto(document, page, item.photoPath, {
        x: photoX,
        y: top - THUMBNAIL_SIZE - 3,
      });

      const textX = photoX + THUMBNAIL_SIZE + 10;
      const lines = __.wrap(
        font,
        __.printable(font, item.title),
        pageWidth - MARGIN - textX,
      );
      _.each(lines, (line, index) => {
        page.drawText(line, {
          x: textX,
          y: top - 14 - index * LINE_HEIGHT,
          size: FONT_SIZE,
          font,
        });
      });
    },
    Promise.resolve(),
  );

  return await document.save();
}

__ = {
  /**
   * Read a photo, shrunk to a thumbnail size to keep the sheet light
   * Phone photos weigh several megabytes, and 40 points of paper do not need
   * them. Uses magick, as the img-resize helper does, because a helper is a
   * shell function that Node cannot call.
   * @param {string} photoPath - Path of the photo
   * @returns {Promise<Buffer>} JPEG bytes
   */
  async readPhoto(photoPath) {
    const { stdout } = await run(
      'magick',
      [
        `${photoPath}[0]`,
        '-auto-orient',
        '-resize',
        `${PHOTO_LONGEST_SIDE}x${PHOTO_LONGEST_SIDE}>`,
        'jpg:-',
      ],
      { encoding: 'buffer' },
    );
    return stdout;
  },

  /**
   * Draw a photo as a thumbnail, or a grey frame when it is not available
   * @param {object} document - pdf-lib document
   * @param {object} page - pdf-lib page
   * @param {string|null} photoPath - Path of the photo
   * @param {object} position - Bottom-left corner of the thumbnail
   * @param {number} position.x - Horizontal position
   * @param {number} position.y - Vertical position
   */
  async drawPhoto(document, page, photoPath, { x, y }) {
    const frame = () =>
      page.drawRectangle({
        x,
        y,
        width: THUMBNAIL_SIZE,
        height: THUMBNAIL_SIZE,
        borderColor: GREY,
        borderWidth: 0.5,
      });
    if (!photoPath) {
      frame();
      return;
    }

    let image = null;
    try {
      image = await document.embedJpg(await __.readPhoto(photoPath));
    } catch {
      // A photo that cannot be read must not stop the sheet
      frame();
      return;
    }
    const fitted = image.scaleToFit(THUMBNAIL_SIZE, THUMBNAIL_SIZE);
    page.drawImage(image, {
      x: x + (THUMBNAIL_SIZE - fitted.width) / 2,
      y: y + (THUMBNAIL_SIZE - fitted.height) / 2,
      width: fitted.width,
      height: fitted.height,
    });
  },

  /**
   * Replace the characters the font cannot draw
   * @param {object} font - pdf-lib font
   * @param {string} text - Text to draw
   * @returns {string} Text the font can encode
   */
  printable(font, text) {
    const replacements = { '’': "'", '‘': "'", '…': '...', ' ': ' ' };
    const supported = font.getCharacterSet();
    return _.chain([...String(text ?? '')])
      .map((char) => replacements[char] ?? char)
      .map((char) => (_.includes(supported, char.codePointAt(0)) ? char : '?'))
      .join('')
      .value();
  },

  /**
   * Break a text into lines that fit a width
   * Keeps at most MAX_LINES lines, and ends the last one with ... when cut.
   * @param {object} font - pdf-lib font
   * @param {string} text - Text to break
   * @param {number} maxWidth - Width of a line, in points
   * @returns {string[]} The lines
   */
  wrap(font, text, maxWidth) {
    const fits = (line) => font.widthOfTextAtSize(line, FONT_SIZE) <= maxWidth;
    const lines = [];
    let current = '';
    _.chain(text)
      .split(' ')
      .each((word) => {
        const candidate = current === '' ? word : `${current} ${word}`;
        if (fits(candidate)) {
          current = candidate;
          return;
        }
        lines.push(current);
        current = word;
      })
      .value();
    lines.push(current);

    const kept = _.chain(lines).compact().take(MAX_LINES).value();
    if (_.compact(lines).length > MAX_LINES) {
      let last = `${_.last(kept)}...`;
      while (!fits(last) && last.length > 4) {
        last = `${last.slice(0, -4)}...`;
      }
      kept[kept.length - 1] = last;
    }
    return kept;
  },

  measureLabel,
};
