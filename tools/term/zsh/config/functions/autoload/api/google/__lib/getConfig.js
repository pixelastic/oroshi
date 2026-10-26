import { env, exists, firostError, readJson } from 'firost';
import { getClientCredentials } from './getClientCredentials.js';
import { loginCommand } from './loginCommand.js';
import { tokensPath } from './tokensPath.js';

export let __;

/**
 * Read the OAuth tokens and the OAuth client of Google
 * @returns {Promise<object>} The tokens of the selected account, the client id and secret, the Drive folder of new Documents and the pandoc reference document
 */
export async function getConfig() {
  const { account } = __;

  // The client comes from the environment, the tokens from the file written by
  // google-login
  const { clientId, clientSecret } = getClientCredentials();
  const path = tokensPath(account);

  // Fail early when the user never logged in
  if (!(await exists(path))) {
    throw firostError('GOOGLE_LOGIN_REQUIRED', loginCommand(account));
  }

  const tokens = await readJson(path);

  // Both are optional: a new Document lands at the root of the Drive without a
  // folder
  const docsFolderId = env('OROSHI_GOOGLE_DRIVE_DOCS_FOLDER_ID');
  const referenceDoc = env('OROSHI_MD2GDOC_REFERENCE_DOC');

  return { tokens, clientId, clientSecret, docsFolderId, referenceDoc };
}

// The account that setAccount changes. Null is the default account
__ = {
  account: null,
};
