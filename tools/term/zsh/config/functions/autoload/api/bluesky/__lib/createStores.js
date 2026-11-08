import { exists, readJson, writeJson } from 'firost';

export let __;

/**
 * Create the state store and the session store of the OAuth client, saved in
 * the tokens file of an account
 * @param {string} path - Path of the tokens file
 * @returns {{stateStore: object, sessionStore: object}} The two stores, as the OAuth client expects them
 */
export function createStores(path) {
  return {
    stateStore: __.createStore(path, 'states'),
    sessionStore: __.createStore(path, 'sessions'),
  };
}

__ = {
  /**
   * Create a store that keeps its entries under one key of the tokens file
   * @param {string} path - Path of the tokens file
   * @param {string} section - Key of the tokens file that holds the entries
   * @returns {object} A store with get, set and del
   */
  createStore(path, section) {
    const read = async () => ((await exists(path)) ? await readJson(path) : {});
    return {
      async get(key) {
        const content = await read();
        return content[section]?.[key];
      },
      async set(key, value) {
        const content = await read();
        content[section] = { ...content[section], [key]: value };
        await writeJson(content, path);
      },
      async del(key) {
        const content = await read();
        delete content[section]?.[key];
        await writeJson(content, path);
      },
    };
  },
};
