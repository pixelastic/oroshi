import { _ } from 'golgoth';
import { consoleError, consoleInfo, consoleSuccess, exit } from 'firost';
import { buildLabelSheets } from '../labelFolder/index.js';

const [labelsDirectory, listingsRoot, outputDirectory] = process.argv.slice(2);

try {
  const report = await buildLabelSheets({
    labelsDirectory,
    listingsRoot,
    outputDirectory,
  });
  consoleSuccess(`${report.written.length} sheet(s) written`);
  _.each(report.withoutListing, ({ label, itemIds }) =>
    consoleInfo(`${label}: no listing found for item ${itemIds.join(', ')}`),
  );
  _.each(report.withoutIndex, (name) =>
    consoleInfo(`${name}: not in the index, no sheet. Run vinted-label-fetch`),
  );
  _.each(report.withoutLabel, (name) =>
    consoleInfo(`${name}: in the index but the PDF is missing`),
  );
} catch (error) {
  consoleError(error.message);
  exit(1);
}
