import { gmailSenderName } from '../senderName.js';

describe('gmailSenderName', () => {
  it.each([
    {
      title: 'keeps the display name',
      from: 'Alice Martin <alice@example.com>',
      expected: 'Alice Martin',
    },
    {
      title: 'removes the quotes around the display name',
      from: '"Alice Martin" <alice@example.com>',
      expected: 'Alice Martin',
    },
    {
      title: 'keeps the raw value when there is no display name',
      from: '<alice@example.com>',
      expected: '<alice@example.com>',
    },
    {
      title: 'keeps a bare address',
      from: 'alice@example.com',
      expected: 'alice@example.com',
    },
  ])('$title', ({ from, expected }) => {
    const actual = gmailSenderName(from);
    expect(actual).toEqual(expected);
  });
});
