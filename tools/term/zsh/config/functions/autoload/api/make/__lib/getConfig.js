import { _ } from 'golgoth';
import { firostError } from 'firost';

export let __;

/**
 * Read the configuration of Make from the environment
 * @returns {Promise<object>} The key, the team ID and the zone of the selected account
 */
export async function getConfig() {
  const { account } = __;

  // The account suffixes each variable: MAKE_DOT_COM_API_KEY_<ACCOUNT>
  const suffix = account ? `_${account.toUpperCase()}` : '';
  const variables = {
    key: `MAKE_DOT_COM_API_KEY${suffix}`,
    teamId: `MAKE_DOT_COM_TEAM_ID${suffix}`,
    zone: `MAKE_DOT_COM_ZONE${suffix}`,
  };

  // Fail early when a variable is empty, and name it
  return _.mapValues(variables, (variable) => {
    const value = process.env[variable];
    if (!value) {
      throw firostError('MAKE_CREDENTIALS_MISSING', `Set ${variable}`);
    }
    return value;
  });
}

// The account that setAccount changes. Null is the default account
__ = {
  account: null,
};
