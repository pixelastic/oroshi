import { PDFDocument, rgb } from 'pdf-lib';

// 1x1 white JPEG
export const TINY_JPEG = Buffer.from(
  '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wAALCAABAAEBAREA/8QAFAABAAAAAAAAAAAAAAAAAAAAA//EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEAAD8AKp//2Q==',
  'base64',
);

/**
 * Build a one-page A4 PDF with a black rectangle, to stand for a label
 * @param {object} rectangle - Rectangle in points, from the top-left corner
 * @param {number} rectangle.x - Left
 * @param {number} rectangle.y - Top
 * @param {number} rectangle.width - Width
 * @param {number} rectangle.height - Height
 * @returns {Promise<Uint8Array>} The PDF bytes
 */
export async function buildFakeLabel({ x, y, width, height }) {
  const document = await PDFDocument.create();
  const page = document.addPage([595.28, 841.89]);
  page.drawRectangle({
    x,
    y: page.getHeight() - y - height,
    width,
    height,
    color: rgb(0, 0, 0),
  });
  return await document.save();
}
