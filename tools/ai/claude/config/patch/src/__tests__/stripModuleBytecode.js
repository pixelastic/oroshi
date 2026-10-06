import { _ } from 'golgoth';
import { stripModuleBytecode } from '../stripModuleBytecode.js';

const TRAILER = '\n---- Bun! ----\n';
const MODULE_SIZE = 52;

/**
 * Build a fake Bun standalone binary:
 * [junk][data][modules table][offsets][trailer]
 * @param {Array} modules - List of { name, contents, bytecode }
 * @returns {Buffer} Fake binary
 */
function buildBinary(modules) {
  const junk = Buffer.from('ELF-HEADER-JUNK');
  const strings = [];
  let cursor = 0;
  const addString = (value) => {
    const buffer = Buffer.from(value, 'latin1');
    strings.push(buffer);
    const pointer = { offset: cursor, length: buffer.length };
    cursor += buffer.length;
    return pointer;
  };

  const pointers = _.map(modules, ({ name, contents, bytecode }) => [
    addString(name),
    addString(contents),
    addString(''),
    addString(bytecode),
    addString(''),
    addString(''),
  ]);
  const data = Buffer.concat(strings);

  const table = Buffer.alloc(modules.length * MODULE_SIZE);
  _.each(pointers, (modulePointers, moduleIndex) => {
    _.each(modulePointers, ({ offset, length }, pointerIndex) => {
      const position = moduleIndex * MODULE_SIZE + pointerIndex * 8;
      table.writeUInt32LE(offset, position);
      table.writeUInt32LE(length, position + 4);
    });
  });

  const offsets = Buffer.alloc(32);
  offsets.writeBigUInt64LE(BigInt(data.length + table.length), 0);
  offsets.writeUInt32LE(data.length, 8);
  offsets.writeUInt32LE(table.length, 12);

  return Buffer.concat([junk, data, table, offsets, Buffer.from(TRAILER)]);
}

/**
 * Read the bytecode length of each module of a fake binary
 * @param {Buffer} binary - Fake binary
 * @param {number} count - Number of modules
 * @returns {number[]} Bytecode length of each module
 */
function bytecodeLengths(binary, count) {
  const tableStart = binary.indexOf(TRAILER) - 32 - count * MODULE_SIZE;
  return _.times(count, (index) =>
    binary.readUInt32LE(tableStart + index * MODULE_SIZE + 3 * 8 + 4),
  );
}

describe('stripModuleBytecode', () => {
  let binary;
  beforeEach(() => {
    binary = buildBinary([
      { name: '/$bunfs/root/cli', contents: 'CLI_SOURCE', bytecode: 'BC1' },
      {
        name: '/$bunfs/root/chunk-a.js',
        contents: 'DIFF_TABLE',
        bytecode: 'BC22',
      },
      {
        name: '/$bunfs/root/chunk-b.js',
        contents: 'CODE_TABLE',
        bytecode: 'BC333',
      },
    ]);
  });

  it('removes the bytecode of modules containing the offsets', () => {
    const offsets = [
      binary.indexOf('DIFF_TABLE') + 2,
      binary.indexOf('CODE_TABLE'),
    ];
    stripModuleBytecode(binary, offsets);
    const actual = bytecodeLengths(binary, 3);
    expect(actual).toEqual([3, 0, 0]);
  });

  it('returns the name of the stripped modules', () => {
    const actual = stripModuleBytecode(binary, [binary.indexOf('DIFF_TABLE')]);
    expect(actual).toEqual(['/$bunfs/root/chunk-a.js']);
  });

  it.each([
    { title: 'Offset outside of any module', input: () => [0] },
    {
      title: 'Offset in bytecode, not contents',
      input: (buffer) => [buffer.indexOf('BC22')],
    },
  ])('throws: $title', ({ input }) => {
    let actual = null;
    try {
      stripModuleBytecode(binary, input(binary));
    } catch (error) {
      actual = error;
    }
    expect(actual).toHaveProperty('code', 'CLAUDE_PATCH_MODULE_NOT_FOUND');
  });

  it('throws when the binary is not a Bun binary', () => {
    let actual = null;
    try {
      stripModuleBytecode(Buffer.from('not a bun binary'), [0]);
    } catch (error) {
      actual = error;
    }
    expect(actual).toHaveProperty('code', 'CLAUDE_PATCH_NOT_BUN');
  });
});
