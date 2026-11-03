import { _ } from 'golgoth';
import { getLabels } from './getLabels.js';

export let __;

/**
 * Find the user labels of Threads, from the label ids of their Messages. The
 * labels are listed once, whatever the number of Threads
 * @param {object[]} threads - Gmail thread resources, with their Messages and the labelIds of each Message
 * @returns {Promise<object[][]>} One list per Thread, in the same order, of { name, backgroundColor }. Sorted by name, each label once, system labels never. backgroundColor is undefined for a label without color
 */
export async function getUserLabelNames(threads) {
  const labels = await __.getLabels();
  const userLabels = _.chain(labels)
    .filter({ type: 'user' })
    .keyBy('labelId')
    .value();

  return _.map(threads, (thread) =>
    _.chain(thread.messages)
      .flatMap('labelIds')
      .uniq()
      .map((labelId) => userLabels[labelId])
      .compact()
      .map((label) => _.pick(label, ['name', 'backgroundColor']))
      .sortBy('name')
      .value(),
  );
}

__ = {
  getLabels,
};
