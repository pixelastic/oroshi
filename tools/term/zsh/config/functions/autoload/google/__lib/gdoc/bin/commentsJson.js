import { gdocCommentsJson } from '../commentsJson.js';

const input = process.argv[2];

if (!input) {
  console.error('Usage: gdoc-comments-json <url-or-doc-id>');
  process.exit(1);
}

const result = await gdocCommentsJson(input);
console.log(JSON.stringify(result));
