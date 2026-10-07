import { writeFile } from 'node:fs/promises';
import path from 'node:path';
import { mkdirp, remove, tmpDirectory } from 'firost';
import { isPatched } from '../isPatched.js';

const ORIGINAL =
  'handleKeyDown:(br)=>{if(br.name==="right"&&!Do){if(LEe(Wo)&&Ie===""){_e(),Fs(Wo.text),br.preventDefault(),br.stopImmediatePropagation();return}}';
const PATCHED = ORIGINAL.replace('"right"', '"down" ');

describe('isPatched', () => {
  let testDirectory;
  let binaryPath;
  beforeEach(async () => {
    testDirectory = tmpDirectory('isPatched');
    await mkdirp(testDirectory);
    binaryPath = path.join(testDirectory, 'claude.exe');
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('returns true when the binary has the patched handler', async () => {
    await writeFile(binaryPath, `AAA${PATCHED}BBB`);
    const actual = await isPatched(binaryPath, 'suggestion');
    expect(actual).toEqual(true);
  });

  it('returns false when the binary has the original handler', async () => {
    await writeFile(binaryPath, `AAA${ORIGINAL}BBB`);
    const actual = await isPatched(binaryPath, 'suggestion');
    expect(actual).toEqual(false);
  });
});
