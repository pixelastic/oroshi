import { __, projectListRaw } from '../projectListRaw.js';

describe('projectListRaw', () => {
  beforeEach(() => {
    vi.spyOn(__, 'projectSearch').mockReturnValue([
      {
        slug: 'gh/pixelastic/firost',
        vcs_info: { default_branch: 'main' },
      },
      { slug: 'gh/pixelastic/golgoth' },
    ]);
  });

  it('searches with the options it received', async () => {
    await projectListRaw({ query: 'fir', limit: '5' });

    expect(__.projectSearch).toHaveBeenCalledWith({ query: 'fir', limit: '5' });
  });

  it('prints the slug first and the default branch second', async () => {
    const actual = await projectListRaw({});

    expect(actual).toEqual('gh/pixelastic/firost▮main\ngh/pixelastic/golgoth▮');
  });

  it('prints one empty line for no project', async () => {
    __.projectSearch.mockReturnValue([]);

    const actual = await projectListRaw({});

    expect(actual).toEqual('');
  });
});

describe('toLine', () => {
  it('removes the separators from the values', () => {
    const actual = __.toLine({
      slug: 'gh/a▮b/c',
      vcs_info: { default_branch: 'feat/x▯y' },
    });

    expect(actual).toEqual('gh/ab/c▮feat/xy');
  });
});
