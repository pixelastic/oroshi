import Gilmore from 'gilmore';
import { commitWithHint } from '../commitWithHint.js';

vi.mock('gilmore', () => ({ default: vi.fn() }));
vi.mock('../getPlanDir.js', () => ({
  getPlanDir: vi.fn().mockReturnValue('/some/plans/commit-message-binary'),
}));

describe('commitWithHint', () => {
  describe('getDiff', () => {
    it.each([
      {
        title: 'binary-only staged files → binary fallback message',
        stagedFilesWithStatus: [
          { name: 'file.nes', status: 'added' },
          {
            name: 'plans/commit-message-binary/state.json',
            status: 'modified',
          },
        ],
        diffs: { 'file.nes': '', 'plans/commit-message-binary/state.json': '' },
        expected: 'Binary files added:\n- file.nes',
      },
      {
        title: 'text files staged → returns raw diff',
        stagedFilesWithStatus: [{ name: 'src/index.js', status: 'modified' }],
        diffs: { 'src/index.js': 'diff text' },
        expected: 'diff text',
      },
      {
        title: 'mixed binary and text → text diff + binary block',
        stagedFilesWithStatus: [
          { name: 'game.nes', status: 'added' },
          { name: 'src/index.js', status: 'modified' },
        ],
        diffs: { 'game.nes': '', 'src/index.js': 'diff text' },
        expected: 'diff text\n\nBinary files added:\n- game.nes',
      },
    ])('$title', async ({ stagedFilesWithStatus, diffs, expected }) => {
      Gilmore.mockReturnValue({
        stagedFilesWithStatus: vi.fn().mockReturnValue(stagedFilesWithStatus),
        run: vi
          .fn()
          .mockImplementation((cmd) => diffs[cmd.split(' ').at(-1)] ?? ''),
      });
      const actual = await commitWithHint.getDiff();
      expect(actual).toEqual(expected);
    });

    it('plan-noise files do not appear in binary fallback', async () => {
      Gilmore.mockReturnValue({
        stagedFilesWithStatus: vi.fn().mockReturnValue([
          { name: 'file.nes', status: 'added' },
          {
            name: 'plans/commit-message-binary/state.json',
            status: 'modified',
          },
          {
            name: 'plans/commit-message-binary/GUIDANCE.md',
            status: 'modified',
          },
          {
            name: 'plans/commit-message-binary/review-log.md',
            status: 'modified',
          },
        ]),
        run: vi.fn().mockReturnValue(''),
      });
      const actual = await commitWithHint.getDiff();
      const expected = 'Binary files added:\n- file.nes';
      expect(actual).toEqual(expected);
    });
  });
});
