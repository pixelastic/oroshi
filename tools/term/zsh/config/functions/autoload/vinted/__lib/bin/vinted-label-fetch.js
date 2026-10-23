import { _ } from 'golgoth';
import { consoleError, consoleInfo, consoleSuccess, exit } from 'firost';
import { fetchLabels, parseSince } from '../labelFolder/index.js';
import { openSession } from '../openSession.js';

const [labelsDirectory, since] = process.argv.slice(2);

const LABELS = {
  saved: 'label saved',
  requested: 'label requested, it arrives later',
  have: 'already have it',
  skipped: 'no label button',
  failed: 'failed',
};

try {
  const context = await openSession();
  try {
    const report = await fetchLabels(context, {
      labelsDirectory,
      since: parseSince(since),
      onProgress: (status, { name, items }) =>
        console.log(`${LABELS[status]}\t${name}\t${items[0].title}`),
    });
    consoleSuccess(
      `${report.saved.length} saved, ${report.requested.length} requested, ${report.have.length} already there, ${report.skipped.length} skipped, ${report.failed.length} failed`,
    );
    if (!_.isEmpty(report.requested)) {
      consoleInfo('Run it again later to get the labels that were requested');
    }
  } finally {
    await context.close();
  }
} catch (error) {
  consoleError(error.message);
  exit(1);
}
