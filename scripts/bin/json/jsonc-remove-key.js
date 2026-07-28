import { exists, read, write } from 'firost';
import { applyEdits, modify, parse } from 'jsonc-parser';

const [filePath, key] = process.argv.slice(2);

if (!(await exists(filePath))) {
  console.error(`File not found: ${filePath}`);
  process.exit(1);
}

const content = await read(filePath);

// Validate JSONC syntax
const errors = [];
parse(content, errors);
if (errors.length > 0) {
  console.error(`Invalid JSONC: ${filePath}`);
  process.exit(1);
}

const edits = modify(content, [key], undefined, {});

if (edits.length === 0) {
  process.exit(0);
}

const result = applyEdits(content, edits);
await write(result, filePath);
