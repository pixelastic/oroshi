import { header } from '../header.js';

describe('header', () => {
  const message = {
    payload: { headers: [{ name: 'Subject', value: 'Hello' }] },
  };

  it.each([
    { title: 'reads the value', name: 'Subject', expected: 'Hello' },
    { title: 'ignores the case', name: 'SUBJECT', expected: 'Hello' },
    { title: 'returns an empty string if missing', name: 'To', expected: '' },
  ])('$title', ({ name, expected }) => {
    const actual = header(message, name);

    expect(actual).toEqual(expected);
  });

  it('returns an empty string for a Message without payload', () => {
    const actual = header({}, 'Subject');

    expect(actual).toEqual('');
  });
});
