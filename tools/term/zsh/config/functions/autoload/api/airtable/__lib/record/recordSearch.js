import { recordSearchPaged } from './recordSearchPaged.js';

export let __;

/**
 * Search the Records of a Table with an Airtable formula
 * @param {object} options - Same options as the paged search
 * @returns {Promise<object[]>} The Records, formatted
 */
export async function recordSearch(options) {
  const { records } = await __.recordSearchPaged(options);
  return records;
}

__ = {
  recordSearchPaged,
};
