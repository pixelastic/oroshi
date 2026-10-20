import { _ } from 'golgoth';

export let __;

/**
 * Merge the groups returned for each batch into one list of items
 * Groups that share a photo are the same item: the largest one gives the
 * identification, and the photos and rotations of all of them are kept.
 * @param {object[][]} batches - Groups returned for each batch
 * @returns {object[]} Merged groups, with rotations and unsure always set
 */
export function mergeGroups(batches) {
  return _.chain(batches)
    .flatten()
    .reduce((merged, group) => {
      const [related, others] = _.partition(
        merged,
        (item) =>
          !_.chain(item.photos).intersection(group.photos).isEmpty().value(),
      );
      return [...others, __.combine([...related, group])];
    }, [])
    .value();
}

__ = {
  /**
   * Combine groups of the same item
   * @param {object[]} groups - Groups of the same item
   * @returns {object} One group
   */
  combine(groups) {
    const largest = _.maxBy(groups, (group) => group.photos.length);
    return {
      ...largest,
      photos: _.chain([largest, ...groups])
        .flatMap('photos')
        .uniq()
        .value(),
      rotations: _.assign({}, ..._.map(groups, 'rotations'), largest.rotations),
      unsure: Boolean(largest.unsure),
    };
  },
};
