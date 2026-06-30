import Gilmore from 'gilmore';
import { getDeletedPlanName } from '../getDeletedPlanName.js';

vi.mock('gilmore', () => ({ default: vi.fn() }));

describe('getDeletedPlanName', () => {
  it.each([
    {
      title: 'Both sentinels deleted — returns slug',
      fileStatuses: [
        { name: 'plans/bats-shebang/PRD.md', status: 'deleted' },
        { name: 'plans/bats-shebang/state.json', status: 'deleted' },
      ],
      expected: 'bats-shebang',
    },
    {
      title: 'One sentinel deleted — still returns slug',
      fileStatuses: [{ name: 'plans/bats-shebang/PRD.md', status: 'deleted' }],
      expected: 'bats-shebang',
    },
    {
      title: 'No deleted sentinels',
      fileStatuses: [],
      expected: null,
    },
    {
      title: 'Plan files added (A status) — returns null',
      fileStatuses: [
        { name: 'plans/parisRbAI/PRD.md', status: 'added' },
        { name: 'plans/parisRbAI/state.json', status: 'added' },
      ],
      expected: null,
    },
    {
      title: 'status() returns false (git error) — returns null',
      fileStatuses: false,
      expected: null,
    },
  ])('$title', async ({ fileStatuses, expected }) => {
    Gilmore.mockReturnValue({
      status: vi.fn().mockReturnValue(fileStatuses),
    });
    const actual = await getDeletedPlanName();
    expect(actual).toEqual(expected);
  });
});
