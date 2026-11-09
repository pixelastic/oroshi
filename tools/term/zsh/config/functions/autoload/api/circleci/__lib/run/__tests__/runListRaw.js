import { __, runListRaw } from '../runListRaw.js';

describe('runListRaw', () => {
  beforeEach(() => {
    vi.spyOn(__, 'runSearch').mockReturnValue([
      {
        id: 'runA',
        project: 'gh/o/r',
        name: 'ci',
        status: 'failed',
        branch: 'main',
        commit: 'abc1234',
        pipelineNumber: 2113,
        createdAt: '2026-11-01T10:00:00Z',
        duration: 85,
        url: 'https://app.circleci.com/pipelines/gh/o/r/2113/workflows/runA',
      },
      { id: 'runB', status: 'running', duration: null },
    ]);
  });

  it('searches with the options it received', async () => {
    await runListRaw({ project: 'gh/o/r', branch: 'main', status: 'failed' });

    expect(__.runSearch).toHaveBeenCalledWith({
      project: 'gh/o/r',
      branch: 'main',
      status: 'failed',
    });
  });

  it('prints the id first, then the other fields, separated by ▮', async () => {
    const actual = await runListRaw({ project: 'gh/o/r' });

    const [first] = actual.split('\n');
    expect(first).toEqual(
      'runA▮gh/o/r▮ci▮failed▮main▮abc1234▮2113▮2026-11-01T10:00:00Z▮85▮https://app.circleci.com/pipelines/gh/o/r/2113/workflows/runA',
    );
  });

  it('leaves an empty column for a null duration', async () => {
    const actual = await runListRaw({ project: 'gh/o/r' });

    const [, second] = actual.split('\n');
    expect(second).toEqual('runB▮▮▮running▮▮▮▮▮▮');
  });

  it('prints one empty line for no run', async () => {
    __.runSearch.mockReturnValue([]);

    const actual = await runListRaw({ project: 'gh/o/r' });

    expect(actual).toEqual('');
  });
});
