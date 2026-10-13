import { firostError } from 'firost';

export let __;

/**
 * Read the configuration of Notion from the environment
 * @returns {Promise<object>} The credentials of the selected account
 */
export async function getConfig() {
  const { account } = __;

  // The account selects the variable: NOTION_TOKEN_<ACCOUNT>
  const suffix = account ? `_${account.toUpperCase()}` : '';
  const variable = `NOTION_TOKEN${suffix}`;
  const token = process.env[variable];

  // Fail early when the variable is empty
  if (!token) {
    throw firostError('NOTION_CREDENTIALS_MISSING', `Set ${variable}`);
  }

  return { token };
}

// The account that setAccount changes. Null is the default account
__ = {
  account: null,
};
