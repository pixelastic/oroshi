import { gmailFormatJson } from '../formatJson.js';

describe('gmailFormatJson', () => {
  it.each([
    {
      title: 'outputs id, from, subject, date and snippet',
      input: [
        {
          id: 'a1',
          from: 'Alice <alice@example.com>',
          subject: 'Hello',
          date: 'Mon, 1 Jan 2026 10:00:00 +0000',
          snippet: 'First line',
        },
      ],
      expected: [
        {
          id: 'a1',
          from: 'Alice <alice@example.com>',
          subject: 'Hello',
          date: 'Mon, 1 Jan 2026 10:00:00 +0000',
          snippet: 'First line',
        },
      ],
    },
    {
      title: 'escapes quotes and newlines',
      input: [
        {
          id: 'b2',
          from: 'bob@example.com',
          subject: 'Re: "Quotes" and\nnewlines',
          date: 'Tue, 2 Jan 2026 10:00:00 +0000',
          snippet: 'Second',
        },
      ],
      expected: [
        {
          id: 'b2',
          from: 'bob@example.com',
          subject: 'Re: "Quotes" and\nnewlines',
          date: 'Tue, 2 Jan 2026 10:00:00 +0000',
          snippet: 'Second',
        },
      ],
    },
    {
      title: 'drops fields that are not part of the output',
      input: [
        {
          id: 'a1',
          from: 'f',
          subject: 's',
          date: 'd',
          snippet: 'x',
          to: 'someone',
          body: 'long body',
        },
      ],
      expected: [
        { id: 'a1', from: 'f', subject: 's', date: 'd', snippet: 'x' },
      ],
    },
    {
      title: 'outputs an empty array when nothing matches',
      input: [],
      expected: [],
    },
  ])('$title', ({ input, expected }) => {
    const actual = JSON.parse(gmailFormatJson(input));
    expect(actual).toEqual(expected);
  });
});
