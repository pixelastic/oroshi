import { _ } from 'golgoth';
import { firostError } from 'firost';

export let __;

const HOSTS = ['circleci.com', 'app.circleci.com'];
const SLUG_PREFIXES = { gh: 'gh', github: 'gh', bb: 'bb', bitbucket: 'bb' };
const VCS = '(?<vcs>[^/]+)/(?<org>[^/]+)/(?<repo>[^/]+)';
const RUN_ID = '(?<runId>[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12})';
// One pattern per form of URL, matched against the path
const PATTERNS = [
  // GitHub status: circleci.com/gh/<org>/<repo>/<job>
  new RegExp(`^/${VCS}/(?<jobNumber>\\d+)$`),
  // Job: app.circleci.com/jobs/github/<org>/<repo>/<job>
  new RegExp(`^/jobs/${VCS}/(?<jobNumber>\\d+)$`),
  // Run, with or without a job
  new RegExp(
    `^/pipelines/${VCS}/\\d+/workflows/${RUN_ID}(?:/jobs/(?<jobNumber>\\d+))?$`,
  ),
];

/**
 * Parse a CircleCI URL into the Project and the Run or the Job it points to
 * @param {string} url - URL of a status, a Job or a Run
 * @returns {object} The project Slug, with the id of the Run and the number of the Job when the URL holds them
 */
export function parseCircleciUrl(url) {
  const invalid = firostError(
    'CIRCLECI_INVALID_ARGUMENT',
    `Not a CircleCI run or job URL: ${url}`,
  );

  const { host, pathname } = __.toUrl(url) ?? {};
  if (!_.includes(HOSTS, host)) {
    throw invalid;
  }

  // Keep the first pattern that matches, without the trailing slash
  const path = _.trimEnd(pathname, '/');
  const groups = _.chain(PATTERNS)
    .map((pattern) => path.match(pattern)?.groups)
    .find(Boolean)
    .value();
  const prefix = SLUG_PREFIXES[groups?.vcs];
  if (!prefix) {
    throw invalid;
  }

  const { org, repo, runId, jobNumber } = groups;
  return _.omitBy(
    {
      project: `${prefix}/${org}/${repo}`,
      runId,
      jobNumber: jobNumber && Number(jobNumber),
    },
    _.isUndefined,
  );
}

__ = {
  /**
   * Parse a text as a URL
   * @param {string} text - The text to parse
   * @returns {URL|null} The URL, or null if the text is not one
   */
  toUrl(text) {
    return URL.canParse(text) ? new URL(text) : null;
  },
};
