import { firostError } from 'firost';

export let __;

/**
 * Read the configuration of CircleCI from the environment
 * @returns {Promise<object>} The token of the selected account
 */
export async function getConfig() {
  const { account } = __;

  // The account suffixes the variable: CIRCLECI_TOKEN_<ACCOUNT>
  const suffix = account ? `_${account.toUpperCase()}` : '';
  const variable = `CIRCLECI_TOKEN${suffix}`;
  const token = process.env[variable];

  // Fail early when the variable is empty, and name it
  if (!token) {
    throw firostError('CIRCLECI_CREDENTIALS_MISSING', `Set ${variable}`);
  }

  return { token };
}

// The account that setAccount changes. Null is the default account
__ = {
  account: null,
};
