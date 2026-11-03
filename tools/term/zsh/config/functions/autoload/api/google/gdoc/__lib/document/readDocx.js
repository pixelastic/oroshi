import { readFile } from 'node:fs/promises';
import { extname } from 'node:path';
import { firostError } from 'firost';
import { getConfig } from '@oroshi/google/getConfig.js';
import { markdownToDocx } from './markdownToDocx.js';

export let __;

/**
 * Read the docx to upload from a Markdown or docx file
 * @param {string} filepath - Path to a .md or .docx file. Throws GDOC_FILE_MISSING if empty, GDOC_FILE_UNSUPPORTED for another extension
 * @returns {Promise<Buffer>} The content of the docx
 */
export async function readDocx(filepath) {
  if (!filepath) {
    throw firostError(
      'GDOC_FILE_MISSING',
      'Pass the path of a .md or .docx file',
    );
  }

  // Only a Markdown file is converted, a docx is uploaded as is
  const extension = extname(filepath);
  if (!['.md', '.docx'].includes(extension)) {
    throw firostError(
      'GDOC_FILE_UNSUPPORTED',
      `${filepath} must be a .md or .docx file`,
    );
  }
  if (extension === '.docx') {
    return await __.readFile(filepath);
  }

  const { referenceDoc } = await __.getConfig();
  return await __.markdownToDocx(filepath, referenceDoc);
}

__ = {
  getConfig,
  markdownToDocx,
  readFile,
};
