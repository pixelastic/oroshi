import { exists, read } from 'firost';
import { getCommitHint } from '../getCommitHint.js';
import { getPlanDir } from '../getPlanDir.js';

vi.mock('../getPlanDir.js', () => ({
  getPlanDir: vi.fn(),
}));
vi.mock('firost', async () => {
  const actual = await vi.importActual('firost');
  return {
    ...actual,
    exists: vi.fn(),
    read: vi.fn(),
  };
});

describe('getCommitHint', () => {
  it('returns hint content when COMMIT_HINT.md exists', async () => {
    getPlanDir.mockReturnValue('/some/plans/foo');
    exists.mockReturnValue(true);
    read.mockReturnValue('hint content');

    const actual = await getCommitHint();

    expect(actual).toEqual('hint content');
  });

  it('returns false when not in a ralph worktree', async () => {
    getPlanDir.mockReturnValue(null);

    const actual = await getCommitHint();

    expect(actual).toEqual(false);
  });

  it('returns false when COMMIT_HINT.md does not exist', async () => {
    getPlanDir.mockReturnValue('/some/plans/foo');
    exists.mockReturnValue(false);

    const actual = await getCommitHint();

    expect(actual).toEqual(false);
  });
});
