import { _ } from 'golgoth';
import { __, pageSearch } from '../pageSearch.js';

describe('pageSearch', () => {
  const searchBaseUrl =
    'https://api.atlassian.com/ex/confluence/cloud-123/wiki/rest/api';

  // A result of the search API
  const result = (id, excerpt = 'Some text') => ({
    title: `Page ${id}`,
    excerpt,
    url: `/spaces/ENG/pages/${id}/Page+${id}`,
    resultGlobalContainer: { title: 'Engineering' },
    content: { id },
  });
  // Serve the results by start and limit, like the API. A response holds at
  // most limit results, and has a next link while more results remain
  const mockResults = (results) => {
    vi.spyOn(__, 'callApi').mockImplementation((path, options) => {
      const { start, limit } = options.query;
      const page = _.slice(results, start, start + limit);
      const hasMore = start + limit < results.length;
      return hasMore
        ? { results: page, _links: { next: '/rest/api/search?next' } }
        : { results: page, _links: {} };
    });
  };

  beforeEach(() => {
    vi.spyOn(__, 'getConfig').mockReturnValue({
      domain: 'work.atlassian.net',
      cloudId: 'cloud-123',
    });
    vi.spyOn(__, 'formatPage').mockImplementation((input) => input);
  });

  it('calls the search endpoint with the CQL and the limit', async () => {
    mockResults([result('1')]);

    await pageSearch({ query: 'meetup', limit: 5 });

    expect(__.callApi).toHaveBeenCalledWith('search', {
      baseUrl: searchBaseUrl,
      query: { cql: 'type = page AND text ~ "meetup"', limit: 5, start: 0 },
    });
  });

  it.each([
    { title: 'uses 25 as the default', input: undefined, expected: 25 },
    {
      title: 'accepts a string, like a flag gives it',
      input: '5',
      expected: 5,
    },
  ])('$title for the limit', async ({ input, expected }) => {
    mockResults([result('1')]);

    await pageSearch({ query: 'meetup', limit: input });

    expect(__.callApi).toHaveBeenCalledWith(
      'search',
      expect.objectContaining({
        query: expect.objectContaining({ limit: expected }),
      }),
    );
  });

  it.each([
    {
      title: 'quotes',
      query: 'say "hi"',
      expected: 'type = page AND text ~ "say \\"hi\\""',
    },
    {
      title: 'backslashes',
      query: 'C:\\temp',
      expected: 'type = page AND text ~ "C:\\\\temp"',
    },
    {
      title: 'a backslash before a quote',
      query: '\\"',
      expected: 'type = page AND text ~ "\\\\\\""',
    },
  ])('escapes $title of the query', async ({ query, expected }) => {
    mockResults([]);

    await pageSearch({ query });

    expect(__.callApi).toHaveBeenCalledWith(
      'search',
      expect.objectContaining({
        query: expect.objectContaining({ cql: expected }),
      }),
    );
  });

  it.each([
    { title: 'an empty query', options: { query: '' } },
    { title: 'a missing query', options: {} },
  ])('throws CONFLUENCE_QUERY_MISSING on $title', async ({ options }) => {
    let actual = null;
    try {
      await pageSearch(options);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CONFLUENCE_QUERY_MISSING');
  });

  it('returns each result formatted, with its url and its space', async () => {
    mockResults([result('1'), result('2')]);

    const actual = await pageSearch({ query: 'meetup' });

    expect(__.formatPage).toHaveBeenCalledWith(result('1'));
    expect(actual).toEqual([
      {
        id: '1',
        title: 'Page 1',
        space: 'Engineering',
        url: 'https://work.atlassian.net/wiki/spaces/ENG/pages/1/Page+1',
        excerpt: 'Some text',
      },
      {
        id: '2',
        title: 'Page 2',
        space: 'Engineering',
        url: 'https://work.atlassian.net/wiki/spaces/ENG/pages/2/Page+2',
        excerpt: 'Some text',
      },
    ]);
  });

  it('removes the highlight markers from excerpts', async () => {
    mockResults([
      result(
        '1',
        'Join the @@@hl@@@Paris@@@endhl@@@ @@@hl@@@meetup@@@endhl@@@',
      ),
    ]);

    const actual = await pageSearch({ query: 'paris meetup' });

    expect(actual).toHaveProperty('0.excerpt', 'Join the Paris meetup');
  });

  it('returns an empty array when there is no result', async () => {
    mockResults([]);

    const actual = await pageSearch({ query: 'nothing' });

    expect(actual).toEqual([]);
  });

  it('paginates up to the limit', async () => {
    mockResults(_.times(250, (index) => result(`${index}`)));

    const actual = await pageSearch({ query: 'meetup', limit: 150 });

    expect(actual).toHaveLength(150);
    expect(__.callApi).toHaveBeenCalledTimes(2);
    expect(__.callApi).toHaveBeenLastCalledWith(
      'search',
      expect.objectContaining({
        query: expect.objectContaining({ limit: 50, start: 100 }),
      }),
    );
  });

  it('stops when the API has no more results', async () => {
    mockResults([result('1'), result('2')]);

    const actual = await pageSearch({ query: 'meetup', limit: 150 });

    expect(actual).toHaveLength(2);
    expect(__.callApi).toHaveBeenCalledTimes(1);
  });
});
