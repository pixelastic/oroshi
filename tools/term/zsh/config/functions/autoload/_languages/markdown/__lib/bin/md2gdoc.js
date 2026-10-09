import { md2gdoc } from '../md2gdoc.js';

const args = process.argv.slice(2);
const options = {};

const noOpenIndex = args.indexOf('--no-open');
if (noOpenIndex !== -1) {
  options.open = false;
  args.splice(noOpenIndex, 1);
}

const titleIndex = args.indexOf('--title');
if (titleIndex !== -1) {
  options.title = args[titleIndex + 1];
  args.splice(titleIndex, 2);
}

const filepath = args[0];
if (!filepath) {
  console.error(
    'Usage: md2gdoc <file.md> [--title "Custom Title"] [--no-open]',
  );
  process.exit(1);
}

const url = await md2gdoc(filepath, options);
console.log(url);
