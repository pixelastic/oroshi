import { buildTitle } from '../buildTitle.js';

describe('buildTitle', () => {
  it('wraps the text in a rich text array', () => {
    const actual = buildTitle('Meetups');

    expect(actual).toEqual([{ type: 'text', text: { content: 'Meetups' } }]);
  });
});
