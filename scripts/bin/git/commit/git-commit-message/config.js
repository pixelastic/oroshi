import Gilmore from 'gilmore';

let repoPath;
let repo;

/**
 * Initialize shared config with an optional repo path.
 * Must be called once before any helper reads the repo.
 * @param {string} [path] - Optional repo root path
 */
export function init(path) {
  repoPath = path;
  repo = Gilmore(path);
}

/**
 * @returns {string|undefined} The repo root path, or undefined for cwd
 */
export function getRepoPath() {
  return repoPath;
}

/**
 * @returns {object} Shared Gilmore instance
 */
export function getRepo() {
  return repo;
}
