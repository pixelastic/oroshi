import { formatPage } from '../formatPage.js';

describe('formatPage', () => {
  it('returns the page as the API gave it', () => {
    const input = { id: '123', title: 'Hello', spaceId: '9' };

    const actual = formatPage(input);

    expect(actual).toEqual(input);
  });
});
