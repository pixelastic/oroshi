import { parseDirectoryId } from '../parseDirectoryId.js';

describe('parseDirectoryId', () => {
  it.each([
    {
      title: 'folder URL',
      input: 'https://drive.google.com/drive/folders/folderA',
      expected: 'folderA',
    },
    {
      title: 'folder URL with ?usp=',
      input: 'https://drive.google.com/drive/folders/folderA?usp=sharing',
      expected: 'folderA',
    },
    {
      title: 'folder URL with /u/0/',
      input: 'https://drive.google.com/drive/u/0/folders/folderA',
      expected: 'folderA',
    },
    {
      title: 'folder URL with /u/0/ and ?usp=',
      input: 'https://drive.google.com/drive/u/0/folders/folderA?usp=sharing',
      expected: 'folderA',
    },
    {
      title: 'bare id',
      input: 'folderA',
      expected: 'folderA',
    },
    {
      title: 'empty value',
      input: undefined,
      expected: undefined,
    },
  ])('$title', ({ input, expected }) => {
    const actual = parseDirectoryId(input);
    expect(actual).toEqual(expected);
  });
});
