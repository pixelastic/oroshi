import { formatDatabase } from '../formatDatabase.js';

describe('formatDatabase', () => {
  const response = {
    object: 'database',
    id: 'dbA',
    url: 'https://www.notion.so/dbA',
    title: [
      { type: 'text', plain_text: 'Paris ' },
      { type: 'text', plain_text: 'Meetups' },
    ],
    icon: { type: 'emoji', emoji: '🎲' },
    parent: { type: 'page_id', page_id: 'pageA' },
    properties: { Name: { id: 'title', name: 'Name', type: 'title' } },
  };

  it('keeps the id, the url, the title and the properties', () => {
    const actual = formatDatabase(response);

    expect(actual).toEqual({
      id: 'dbA',
      url: 'https://www.notion.so/dbA',
      title: 'Paris Meetups',
      properties: { Name: { id: 'title', name: 'Name', type: 'title' } },
    });
  });

  it('drops the icon and the parent', () => {
    const actual = formatDatabase(response);

    expect(actual).not.toHaveProperty('icon');
    expect(actual).not.toHaveProperty('parent');
  });
});
