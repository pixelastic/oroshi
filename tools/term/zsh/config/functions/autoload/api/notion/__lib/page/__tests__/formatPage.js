import { formatPage } from '../formatPage.js';

describe('formatPage', () => {
  const response = {
    object: 'page',
    id: 'pageA',
    url: 'https://www.notion.so/pageA',
    icon: { type: 'emoji', emoji: '🎲' },
    cover: { type: 'external', external: { url: 'https://example.com/a.png' } },
    parent: { type: 'database_id', database_id: 'dbA' },
    properties: { Name: { type: 'title', title: [] } },
  };

  it('keeps the id, the url and the properties', () => {
    const actual = formatPage(response);

    expect(actual).toEqual({
      id: 'pageA',
      url: 'https://www.notion.so/pageA',
      properties: { Name: { type: 'title', title: [] } },
    });
  });

  it('drops the icon and the cover', () => {
    const actual = formatPage(response);

    expect(actual).not.toHaveProperty('icon');
    expect(actual).not.toHaveProperty('cover');
  });
});
