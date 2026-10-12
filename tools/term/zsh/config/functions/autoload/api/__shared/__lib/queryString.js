import { _ } from 'golgoth';

export let __;

/**
 * Serialize query parameters the way APIs with bracket syntax expect them. A
 * list is sent as `key[]`, a list of objects as `key[index][property]`. Nil
 * values and empty lists are skipped
 * @param {object} [query] - Query parameters
 * @returns {string} The query string with its leading ?, or an empty string
 */
export function queryString(query) {
  const params = _.chain(query)
    .flatMap((value, key) => __.queryParams(key, value))
    .join('&')
    .value();
  return params ? `?${params}` : '';
}

__ = {
  /**
   * Serialize one query parameter
   * @param {string} key - Parameter name
   * @param {*} value - Scalar, list of scalars or list of objects
   * @returns {string[]} One `key=value` entry per value, none for an empty one
   */
  queryParams(key, value) {
    if (_.isNil(value)) {
      return [];
    }
    if (!_.isArray(value)) {
      return [`${key}=${encodeURIComponent(value)}`];
    }
    return _.flatMap(value, (item, index) =>
      _.isPlainObject(item)
        ? _.map(
            item,
            (property, name) =>
              `${encodeURIComponent(`${key}[${index}][${name}]`)}=${encodeURIComponent(property)}`,
          )
        : [`${encodeURIComponent(`${key}[]`)}=${encodeURIComponent(item)}`],
    );
  },
};
