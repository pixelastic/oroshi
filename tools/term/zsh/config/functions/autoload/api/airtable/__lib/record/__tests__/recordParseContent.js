import { remove, tmpDirectory, write } from 'firost';
import { recordParseContent } from '../recordParseContent.js';

describe('recordParseContent', () => {
  let testDirectory;
  let dataFile;
  beforeEach(async () => {
    testDirectory = tmpDirectory('airtable/recordParseContent');
    dataFile = `${testDirectory}/content.json`;
    await write('{"Name":"From file"}', dataFile);
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it.each([
    {
      title: 'parses the inline JSON',
      options: { content: '{"Name":"Paris","Seats":80}' },
      expected: { Name: 'Paris', Seats: 80 },
    },
    {
      title: 'reads the data file',
      options: { dataFile: true },
      expected: { Name: 'From file' },
    },
    {
      title: 'prefers the data file over the inline JSON',
      options: { dataFile: true, content: '{"Name":"Inline"}' },
      expected: { Name: 'From file' },
    },
    {
      title: 'returns an object as is',
      options: { content: { Name: 'Object' } },
      expected: { Name: 'Object' },
    },
  ])('$title', async ({ options, expected }) => {
    const input = options.dataFile ? { ...options, dataFile } : options;

    const actual = await recordParseContent(input);

    expect(actual).toEqual(expected);
  });

  it.each([
    { title: 'is not JSON', options: { content: '{Name:' } },
    { title: 'is a JSON array', options: { content: '[1,2]' } },
    { title: 'is missing', options: {} },
  ])('throws a clear error when the content $title', async ({ options }) => {
    let actual = null;
    try {
      await recordParseContent(options);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_CONTENT_INVALID');
  });
});
