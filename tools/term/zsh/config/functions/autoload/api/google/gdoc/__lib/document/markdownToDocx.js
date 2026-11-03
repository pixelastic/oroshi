import { readFile } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { mkdirp, remove, run, tmpDirectory } from 'firost';

export let __;

/**
 * Convert a Markdown file to docx with pandoc
 * @param {string} filepath - Path to the Markdown file
 * @param {string} referenceDoc - Path to the pandoc reference document
 * @returns {Promise<Buffer>} Content of the docx
 */
export async function markdownToDocx(filepath, referenceDoc) {
  const workDirectory = tmpDirectory('markdownToDocx');
  const docxPath = join(workDirectory, 'output.docx');
  // Pandoc runs from the folder of the file, so the path must be absolute
  const absolutePath = resolve(filepath);

  try {
    await __.mkdirp(workDirectory);
    await __.run(
      [
        'pandoc',
        '-f',
        'markdown-auto_identifiers',
        absolutePath,
        '-o',
        docxPath,
        `--reference-doc=${referenceDoc}`,
        `--extract-media=${workDirectory}/`,
      ],
      { cwd: dirname(absolutePath), stdout: false, stderr: false },
    );
    return await __.readFile(docxPath);
  } finally {
    await __.remove(workDirectory);
  }
}

__ = {
  mkdirp,
  readFile,
  remove,
  run,
};
