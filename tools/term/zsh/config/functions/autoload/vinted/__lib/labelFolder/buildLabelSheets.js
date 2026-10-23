import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { _ } from 'golgoth';
import { exists, glob } from 'firost';
import { buildLabelSheet } from './buildLabelSheet.js';
import { findListings } from './findListings.js';
import { readLabelIndex } from './readLabelIndex.js';
import { writeBinary } from './writeBinary.js';

/**
 * Build the sheet of every indexed label, from the label and the listings
 * An item with no listing keeps its title from the inbox, and is reported.
 * @param {object} input - Input
 * @param {string} input.labelsDirectory - Folder holding the label PDFs and index.json
 * @param {string} input.listingsRoot - Folder holding the listing JSON files
 * @param {string} input.outputDirectory - Folder to write the sheets in
 * @returns {Promise<object>} What was done: written, withoutListing,
 * withoutIndex and withoutLabel
 */
export async function buildLabelSheets({
  labelsDirectory,
  listingsRoot,
  outputDirectory,
}) {
  const index = await readLabelIndex(labelsDirectory);
  const listings = await findListings(listingsRoot);
  const report = {
    written: [],
    withoutListing: [],
    withoutIndex: [],
    withoutLabel: [],
  };

  await _.chain(index)
    .keys()
    .sortBy()
    .reduce(async (previous, name) => {
      await previous;
      const labelPath = path.join(labelsDirectory, name);
      if (!(await exists(labelPath))) {
        report.withoutLabel.push(name);
        return;
      }

      const items = _.map(index[name].items, ({ id, title }) => ({
        title: listings[id]?.title ?? title,
        photoPath: listings[id]?.photoPath ?? null,
      }));
      const missing = _.chain(index[name].items)
        .reject(({ id }) => listings[id])
        .map('id')
        .value();
      if (!_.isEmpty(missing)) {
        report.withoutListing.push({ label: name, itemIds: missing });
      }

      const sheet = await buildLabelSheet({
        labelBytes: await readFile(labelPath),
        labelPath,
        items,
      });
      await writeBinary(sheet, path.join(outputDirectory, name));
      report.written.push(name);
    }, Promise.resolve())
    .value();

  const labelFiles = _.map(
    await glob('*.pdf', { cwd: labelsDirectory }),
    (file) => path.basename(file),
  );
  report.withoutIndex = _.chain(labelFiles)
    .difference(_.keys(index))
    .sortBy()
    .value();
  return report;
}
