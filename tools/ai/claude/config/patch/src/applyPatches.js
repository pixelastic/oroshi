import { _ } from 'golgoth';
import { firostError } from 'firost';
import { patchBinary } from './patchBinary.js';
import { patches } from './patches.js';

/**
 * Apply registered patches to the Claude Code binary.
 * Patches already present in the binary are skipped.
 * @param {string} binaryPath - Path to the claude.exe binary
 * @param {string[]} names - Names of the patches to apply
 * @returns {Promise<boolean>} True when the binary was rewritten
 * @throws {Error} CLAUDE_PATCH_UNKNOWN when a name is not registered
 */
export async function applyPatches(binaryPath, names) {
  const contracts = _.map(names, (name) => {
    if (!_.has(patches, name)) {
      throw firostError(
        'CLAUDE_PATCH_UNKNOWN',
        `Unknown patch "${name}", expected one of: ${_.chain(patches).keys().join(', ').value()}`,
      );
    }
    return patches[name];
  });

  return await patchBinary(binaryPath, (input) =>
    _.reduce(
      contracts,
      (current, contract) => {
        if (contract.isPatched(current.text)) {
          return current;
        }
        const { text, offsets } = contract.patch(current.text);
        return { text, offsets: [...current.offsets, ...offsets] };
      },
      { text: input, offsets: [] },
    ),
  );
}
