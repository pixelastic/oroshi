import { parseId } from '../parseId.js';

describe('parseId', () => {
  const dashed = '3e07be57-b8fa-81bc-b066-c0275ed4b363';
  const bare = '3e07be57b8fa81bcb066c0275ed4b363';

  it.each([
    { title: 'a dashed id', input: dashed },
    { title: 'a 32-character id', input: bare },
    {
      title: 'a canonical page URL',
      input: `https://www.notion.so/workspace/Paris-Meetup-${bare}`,
    },
    {
      title: 'a page URL without title',
      input: `https://app.notion.com/p/${bare}`,
    },
    {
      title: 'a preview URL with p=',
      input: `https://www.notion.so/workspace/Board?v=3e07be57b8fa81bcb066c0275ed4b999&p=${bare}&pm=s`,
    },
    {
      title: 'a database URL, ignoring the view id',
      input: `https://www.notion.so/workspace/${bare}?v=3e07be57b8fa81bcb066c0275ed4b999`,
    },
  ])('returns the dashed id of $title', ({ input }) => {
    const actual = parseId(input);

    expect(actual).toEqual(dashed);
  });

  it.each([
    { title: 'an empty value', input: '' },
    { title: 'a missing value', input: undefined },
    { title: 'text without id', input: 'https://www.notion.so/workspace/Home' },
  ])('throws on $title', ({ input }) => {
    let actual = null;
    try {
      parseId(input);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'NOTION_ID_INVALID');
  });
});
