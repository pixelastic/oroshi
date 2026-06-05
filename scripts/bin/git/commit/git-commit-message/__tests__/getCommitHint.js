import { __, getCommitHint } from '../getCommitHint.js';

describe('getCommitHint', () => {
  it('returns null when plan-directory exits non-zero', async () => {
    vi.spyOn(__, 'getPlanDir').mockReturnValue(null);

    const actual = await getCommitHint();

    expect(actual).toBeNull();
  });

  it('returns null when plan-directory succeeds but COMMIT_HINT does not exist', async () => {
    vi.spyOn(__, 'getPlanDir').mockReturnValue('/plan/dir/');
    vi.spyOn(__, 'hintExists').mockReturnValue(false);

    const actual = await getCommitHint();

    expect(actual).toBeNull();
  });

  it('returns file content when plan-directory succeeds and COMMIT_HINT exists', async () => {
    vi.spyOn(__, 'getPlanDir').mockReturnValue('/plan/dir/');
    vi.spyOn(__, 'hintExists').mockReturnValue(true);
    vi.spyOn(__, 'readHint').mockReturnValue(
      'feat(scope): implement the feature',
    );

    const actual = await getCommitHint();

    expect(actual).toBe('feat(scope): implement the feature');
  });
});
