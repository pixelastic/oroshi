import { gmailFormatRaw } from '../__lib/gmailFormatRaw.js';

describe('gmailFormatRaw', () => {
  it.each([
    {
      title: 'joins id, subject and first content line with ▮',
      message: { id: 'a1', subject: 'Hello', snippet: 'First line' },
      expected: 'a1▮Hello▮First line',
    },
    {
      title: 'strips newlines from the subject',
      message: { id: 'a1', subject: 'Hel\nlo\r\nworld', snippet: 'x' },
      expected: 'a1▮Hel lo world▮x',
    },
    {
      title: 'keeps only the first line of the content',
      message: { id: 'a1', subject: 'S', snippet: 'one\ntwo\nthree' },
      expected: 'a1▮S▮one',
    },
    {
      title: 'strips carriage returns from the content line',
      message: { id: 'a1', subject: 'S', snippet: 'one\r\ntwo' },
      expected: 'a1▮S▮one',
    },
    {
      title: 'handles empty subject and snippet',
      message: { id: 'a1', subject: '', snippet: '' },
      expected: 'a1▮▮',
    },
  ])('$title', ({ message, expected }) => {
    const actual = gmailFormatRaw(message);
    expect(actual).toEqual(expected);
  });
});
