import { _ } from 'golgoth';
import { firostError } from 'firost';

export let __;

/**
 * Read the configuration of Confluence from the environment
 * @returns {Promise<object>} The credentials of the selected account
 */
export async function getConfig() {
  const { account } = __;

  // The account selects the variables: CONFLUENCE_TOKEN_<ACCOUNT>
  const suffix = account ? `_${account.toUpperCase()}` : '';
  const variables = {
    email: `CONFLUENCE_EMAIL${suffix}`,
    token: `CONFLUENCE_TOKEN${suffix}`,
    cloudId: `CONFLUENCE_CLOUD_ID${suffix}`,
    domain: `CONFLUENCE_DOMAIN${suffix}`,
  };

  return _.mapValues(variables, (variable) => {
    // Fail early when a variable is empty
    if (!process.env[variable]) {
      throw firostError('CONFLUENCE_CREDENTIALS_MISSING', `Set ${variable}`);
    }
    return process.env[variable];
  });
}

// The account that setAccount changes. Null is the default account
__ = {
  account: null,
};
