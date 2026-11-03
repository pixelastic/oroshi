import { __, pageListRaw } from '../pageListRaw.js';

describe('pageListRaw', () => {
  beforeEach(() => {
    vi.spyOn(__, 'pageSearch').mockReturnValue([
      {
        id: '1',
        title: 'Page one',
        space: 'Engineering',
        url: 'https://work.atlassian.net/wiki/spaces/ENG/pages/1',
        excerpt: 'Some text',
      },
      {
        id: '2',
        title: 'Page two',
        space: 'Design',
        url: 'https://work.atlassian.net/wiki/spaces/DES/pages/2',
        excerpt: 'Other text',
      },
    ]);
  });

  it('passes its options to the search', async () => {
    await pageListRaw({ query: 'meetup', limit: '5' });

    expect(__.pageSearch).toHaveBeenCalledWith({ query: 'meetup', limit: '5' });
  });

  it('returns one line per page', async () => {
    const actual = await pageListRaw({ query: 'meetup' });

    expect(actual).toEqual(
      [
        '1▮Page one▮Engineering▮https://work.atlassian.net/wiki/spaces/ENG/pages/1',
        '2▮Page two▮Design▮https://work.atlassian.net/wiki/spaces/DES/pages/2',
      ].join('\n'),
    );
  });

  it('returns an empty string without result', async () => {
    __.pageSearch.mockReturnValue([]);

    const actual = await pageListRaw({ query: 'nothing' });

    expect(actual).toEqual('');
  });

  describe('toLine', () => {
    it.each([
      {
        title: 'joins the id, title, space and url',
        input: { id: '1', title: 'Title', space: 'ENG', url: 'https://a.b/1' },
        expected: '1▮Title▮ENG▮https://a.b/1',
      },
      {
        title: 'keeps empty columns',
        input: { id: '1', title: '', space: '', url: 'https://a.b/1' },
        expected: '1▮▮▮https://a.b/1',
      },
      {
        title: 'removes separators and newlines from values',
        input: {
          id: '1',
          title: 'Line one\nLine▮two▯three',
          space: 'ENG',
          url: 'https://a.b/1',
        },
        expected: '1▮Line one Linetwothree▮ENG▮https://a.b/1',
      },
    ])('$title', ({ input, expected }) => {
      const actual = __.toLine(input);

      expect(actual).toEqual(expected);
    });
  });
});
