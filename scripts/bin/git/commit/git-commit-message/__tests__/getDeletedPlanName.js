import { exists } from 'firost';
import Gilmore from 'gilmore';
import { getDeletedPlanName } from '../getDeletedPlanName.js';

vi.mock('gilmore', () => ({ default: vi.fn() }));
vi.mock('firost', () => ({
  absolute: (_base, filepath) => filepath,
  exists: vi.fn(),
  gitRoot: () => '',
}));

describe('getDeletedPlanName', () => {
  it.each([
    {
      title: 'Both sentinels deleted — returns slug',
      stagedPaths: [
        'plans/bats-shebang/PRD.md',
        'plans/bats-shebang/state.json',
      ],
      expected: 'bats-shebang',
    },
    {
      title: 'One sentinel deleted — still returns slug',
      stagedPaths: ['plans/bats-shebang/PRD.md'],
      expected: 'bats-shebang',
    },
    {
      title: 'No deleted sentinels',
      stagedPaths: [],
      expected: null,
    },
  ])('$title', async ({ stagedPaths, expected }) => {
    Gilmore.mockReturnValue({
      stagedFiles: vi.fn().mockReturnValue(stagedPaths),
    });
    exists.mockReturnValue(false);
    const actual = await getDeletedPlanName();
    expect(actual).toEqual(expected);
  });
});
