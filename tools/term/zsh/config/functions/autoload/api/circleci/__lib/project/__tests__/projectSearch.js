import { __, projectSearch } from '../projectSearch.js';

describe('projectSearch', () => {
  // Minimal v1.1 projects: only the fields the module reads
  const response = [
    {
      username: 'pixelastic',
      reponame: 'firost',
      vcs_type: 'github',
      vcs_url: 'https://github.com/pixelastic/firost',
      default_branch: 'main',
    },
    {
      username: 'pixelastic',
      reponame: 'golgoth',
      vcs_type: 'github',
      vcs_url: 'https://github.com/pixelastic/golgoth',
      default_branch: 'master',
    },
    {
      username: 'Algolia',
      reponame: 'Docs',
      vcs_type: 'github',
      vcs_url: 'https://github.com/Algolia/Docs',
      default_branch: 'main',
    },
  ];

  /**
   * Get the slugs of the projects returned by the search
   * @param {object} [options] - Options of the search
   * @returns {Promise<string[]>} The slugs
   */
  async function searchSlugs(options = {}) {
    const actual = await projectSearch(options);
    return actual.map((project) => project.slug);
  }

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue(response);
    vi.spyOn(__, 'formatProject').mockImplementation((project) => project);
  });

  it('calls the v1.1 projects endpoint once', async () => {
    await projectSearch({});

    expect(__.callApi).toHaveBeenCalledTimes(1);
    expect(__.callApi).toHaveBeenCalledWith('projects', {
      baseUrl: 'https://circleci.com/api/v1.1',
    });
  });

  it('builds the slug from the v1.1 fields', async () => {
    const actual = await projectSearch({});

    expect(actual).toHaveProperty('0', {
      slug: 'gh/pixelastic/firost',
      name: 'firost',
      vcs_info: {
        vcs_url: 'https://github.com/pixelastic/firost',
        default_branch: 'main',
      },
    });
  });

  it('returns every project without a query', async () => {
    const actual = await searchSlugs({});

    expect(actual).toEqual([
      'gh/pixelastic/firost',
      'gh/pixelastic/golgoth',
      'gh/Algolia/Docs',
    ]);
  });

  it.each([
    {
      title: 'a part of the slug',
      query: 'golg',
      expected: ['gh/pixelastic/golgoth'],
    },
    {
      title: 'in another case',
      query: 'FIROST',
      expected: ['gh/pixelastic/firost'],
    },
    {
      title: 'the organization',
      query: 'pixelastic',
      expected: ['gh/pixelastic/firost', 'gh/pixelastic/golgoth'],
    },
    { title: 'nothing', query: 'nope', expected: [] },
  ])('keeps the projects matching $title', async ({ query, expected }) => {
    const actual = await searchSlugs({ query });

    expect(actual).toEqual(expected);
  });

  it.each([
    { title: 'a number', limit: 1, expected: ['gh/pixelastic/firost'] },
    { title: 'a string', limit: '1', expected: ['gh/pixelastic/firost'] },
  ])('caps the result with $title as limit', async ({ limit, expected }) => {
    const actual = await searchSlugs({ limit });

    expect(actual).toEqual(expected);
  });

  it('caps the result after the query', async () => {
    const actual = await searchSlugs({ query: 'pixelastic', limit: 1 });

    expect(actual).toEqual(['gh/pixelastic/firost']);
  });

  it('caps the result to 25 by default', async () => {
    const many = Array.from({ length: 30 }, (_value, index) => ({
      username: 'pixelastic',
      reponame: `repo${index}`,
      vcs_type: 'github',
    }));
    __.callApi.mockReturnValue(many);

    const actual = await projectSearch({});

    expect(actual).toHaveLength(25);
  });

  it('returns the projects formatted', async () => {
    __.formatProject.mockReturnValue({ slug: 'formatted' });

    const actual = await projectSearch({ limit: 1 });

    expect(actual).toEqual([{ slug: 'formatted' }]);
  });

  it.each([
    { title: 'zero', limit: 0, shown: '0' },
    { title: 'negative', limit: -1, shown: '-1' },
    { title: 'a decimal', limit: 1.5, shown: '1.5' },
    { title: 'not a number', limit: 'ten', shown: 'ten' },
    { title: 'empty', limit: '', shown: '' },
  ])('throws when the limit is $title', async ({ limit, shown }) => {
    let actual = null;
    try {
      await projectSearch({ limit });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_INVALID_ARGUMENT');
    expect(actual).toHaveProperty(
      'message',
      `--limit must be a positive integer, got "${shown}"`,
    );
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
