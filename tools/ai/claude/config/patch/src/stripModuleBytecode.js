import { _ } from 'golgoth';
import { firostError } from 'firost';

// Bun standalone binary layout: [data][modules table][offsets][trailer]
// Pointers ({ u32 offset, u32 length }) are relative to the start of [data]
const TRAILER = Buffer.from('\n---- Bun! ----\n');
const OFFSETS_SIZE = 32;
// 6 pointers (name, contents, sourcemap, bytecode, moduleInfo,
// bytecodeOriginPath) + 4 u8 (encoding, loader, moduleFormat, side)
const MODULE_SIZE = 52;
const POINTER_SIZE = 8;
const NAME_POINTER = 0;
const CONTENTS_POINTER = 1;
const BYTECODE_POINTER = 3;

export let __;

/**
 * Remove the precompiled bytecode of the modules containing the given
 * offsets, forcing Bun to compile them from their (patched) source instead.
 * Mutates the buffer in place, without changing its size.
 * @param {Buffer} binary - Content of the Claude Code binary
 * @param {number[]} offsets - Byte offsets of patched source code
 * @returns {string[]} Names of the stripped modules
 */
export function stripModuleBytecode(binary, offsets) {
  const modules = __.readModules(binary);

  return _.map(offsets, (offset) => {
    const module = _.find(
      modules,
      ({ contentsStart, contentsEnd }) =>
        offset >= contentsStart && offset < contentsEnd,
    );
    if (!module) {
      throw firostError(
        'CLAUDE_PATCH_MODULE_NOT_FOUND',
        `No module contains offset ${offset}`,
      );
    }

    binary.writeUInt32LE(0, module.bytecodeLengthPosition);
    return module.name;
  });
}

__ = {
  /**
   * List all modules embedded in a Bun standalone binary
   * @param {Buffer} binary - Content of the binary
   * @returns {Array} List of { name, contentsStart, contentsEnd, bytecodeLengthPosition }
   */
  readModules(binary) {
    const trailerPosition = binary.lastIndexOf(TRAILER);
    const offsetsPosition = trailerPosition - OFFSETS_SIZE;
    if (trailerPosition === -1 || offsetsPosition < 0) {
      throw firostError(
        'CLAUDE_PATCH_NOT_BUN',
        'Binary is not a Bun standalone executable',
      );
    }

    const byteCount = Number(binary.readBigUInt64LE(offsetsPosition));
    const dataStart = offsetsPosition - byteCount;
    const tableStart = dataStart + binary.readUInt32LE(offsetsPosition + 8);
    const tableLength = binary.readUInt32LE(offsetsPosition + 12);

    return _.times(tableLength / MODULE_SIZE, (index) => {
      const moduleStart = tableStart + index * MODULE_SIZE;
      const readPointer = (pointerIndex) => {
        const position = moduleStart + pointerIndex * POINTER_SIZE;
        const start = dataStart + binary.readUInt32LE(position);
        const length = binary.readUInt32LE(position + 4);
        return { start, end: start + length, lengthPosition: position + 4 };
      };
      const name = readPointer(NAME_POINTER);
      const contents = readPointer(CONTENTS_POINTER);

      return {
        name: binary.toString('utf8', name.start, name.end),
        contentsStart: contents.start,
        contentsEnd: contents.end,
        bytecodeLengthPosition: readPointer(BYTECODE_POINTER).lengthPosition,
      };
    });
  },
};
