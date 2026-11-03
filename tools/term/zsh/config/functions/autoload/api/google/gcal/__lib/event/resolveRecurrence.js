import { _ } from 'golgoth';

const RULE_PREFIX = 'RRULE:';

/**
 * Turn the --recurrence flag into the recurrence array of the API. The rule is
 * not validated: the API rejects an invalid one
 * @param {string} [recurrence] - RFC 5545 rule, with or without the RRULE: prefix
 * @returns {string[]|undefined} The recurrence of the API, an empty array for an empty value (it removes the recurrence), or undefined when the flag is not passed
 */
export function resolveRecurrence(recurrence) {
  if (_.isUndefined(recurrence)) {
    return undefined;
  }
  if (recurrence === '') {
    return [];
  }

  return [
    _.startsWith(recurrence, RULE_PREFIX)
      ? recurrence
      : `${RULE_PREFIX}${recurrence}`,
  ];
}
