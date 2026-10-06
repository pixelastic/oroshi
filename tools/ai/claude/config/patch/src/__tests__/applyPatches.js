import { chmod, readFile, readdir, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { _ } from 'golgoth';
import { mkdirp, remove, tmpDirectory } from 'firost';
import { applyPatches } from '../applyPatches.js';

const TRAILER = '\n---- Bun! ----\n';
const MODULE_SIZE = 52;
const HANDLER =
  'handleKeyDown:(br)=>{if(br.name==="right"&&!Do){if(LEe(Wo)&&Ie===""){_e(),Fs(Wo.text),br.preventDefault(),br.stopImmediatePropagation();return}}';

/**
 * Build a fake Bun standalone binary with one module and its bytecode:
 * [junk][data][modules table][offsets][trailer]
 * @param {string} contents - Source of the module
 * @returns {Buffer} Fake binary
 */
function buildBinary(contents) {
  const strings = _.map(
    ['/$bunfs/root/cli', contents, '', 'BYTECODE', '', ''],
    (value) => Buffer.from(value, 'latin1'),
  );
  const data = Buffer.concat(strings);

  const table = Buffer.alloc(MODULE_SIZE);
  let cursor = 0;
  _.each(strings, (string, pointerIndex) => {
    table.writeUInt32LE(cursor, pointerIndex * 8);
    table.writeUInt32LE(string.length, pointerIndex * 8 + 4);
    cursor += string.length;
  });

  const offsets = Buffer.alloc(32);
  offsets.writeBigUInt64LE(BigInt(data.length + table.length), 0);
  offsets.writeUInt32LE(data.length, 8);
  offsets.writeUInt32LE(table.length, 12);

  return Buffer.concat([
    Buffer.from('ELF-HEADER-JUNK'),
    data,
    table,
    offsets,
    Buffer.from(TRAILER),
  ]);
}

describe('applyPatches', () => {
  let testDirectory;
  let binaryPath;
  let original;
  beforeEach(async () => {
    testDirectory = tmpDirectory('applyPatches');
    await mkdirp(testDirectory);
    binaryPath = path.join(testDirectory, 'claude.exe');
    original = buildBinary(`AAA${HANDLER}BBB`);
    await writeFile(binaryPath, original);
    await chmod(binaryPath, 0o751);
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  describe('registered patch', () => {
    beforeEach(async () => {
      await applyPatches(binaryPath, ['suggestion']);
    });

    it('changes the file only at the patched offsets', async () => {
      const actual = await readFile(binaryPath);
      const changed = _.chain(original.length)
        .range()
        .filter((index) => actual[index] !== original[index])
        .value();
      // "right" → "down " changes the 6 bytes after the opening quote
      const keyOffset = original.indexOf('"right"');
      // The module bytecode length (8 bytes) is zeroed: only its low byte changes
      const bytecodeLengthOffset =
        original.indexOf(TRAILER) - 32 - MODULE_SIZE + 3 * 8 + 4;
      expect(changed).toEqual([
        keyOffset + 1,
        keyOffset + 2,
        keyOffset + 3,
        keyOffset + 4,
        keyOffset + 5,
        keyOffset + 6,
        bytecodeLengthOffset,
      ]);
      expect(actual.toString('latin1')).toContain('br.name==="down" &&!Do');
    });

    it('keeps the file length', async () => {
      const actual = await readFile(binaryPath);
      expect(actual).toHaveLength(original.length);
    });

    it('keeps the file mode', async () => {
      const actual = (await stat(binaryPath)).mode & 0o777;
      expect(actual).toEqual(0o751);
    });

    it('leaves no temporary file', async () => {
      const actual = await readdir(testDirectory);
      expect(actual).toEqual(['claude.exe']);
    });
  });

  it('leaves an already patched binary byte-identical', async () => {
    await applyPatches(binaryPath, ['suggestion']);
    const patched = await readFile(binaryPath);
    await applyPatches(binaryPath, ['suggestion']);
    const actual = await readFile(binaryPath);
    expect(actual.equals(patched)).toEqual(true);
  });

  it('throws on an unknown patch name', async () => {
    let actual = null;
    try {
      await applyPatches(binaryPath, ['nope']);
    } catch (error) {
      actual = error;
    }
    expect(actual).toHaveProperty('code', 'CLAUDE_PATCH_UNKNOWN');
    expect(actual).toHaveProperty(
      'message',
      'Unknown patch "nope", expected one of: suggestion',
    );
  });
});
