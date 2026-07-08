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
        stagedFiles: ['file.nes', 'plans/commit-message-binary/state.json'],
        diffs: { 'file.nes': '', 'plans/commit-message-binary/state.json': '' },
        expected: 'Binary files added:\n- file.nes',
      },
      {
        title: 'text files staged → returns raw diff',
        stagedFiles: ['src/index.js'],
        diffs: { 'src/index.js': 'diff text' },
        expected: 'diff text',
      },
      {
        title: 'mixed binary and text → text diff only',
        stagedFiles: ['game.nes', 'src/index.js'],
        diffs: { 'game.nes': '', 'src/index.js': 'diff text' },
        expected: 'diff text',
      },
    ])('$title', async ({ stagedFiles, diffs, expected }) => {
      Gilmore.mockReturnValue({
        stagedFiles: vi.fn().mockReturnValue(stagedFiles),
        run: vi
          .fn()
          .mockImplementation((cmd) => diffs[cmd.split(' ').at(-1)] ?? ''),
      });
      const actual = await commitWithHint.getDiff();
      expect(actual).toEqual(expected);
    });

    it('plan-noise files do not appear in binary fallback', async () => {
      Gilmore.mockReturnValue({
        stagedFiles: vi
          .fn()
          .mockReturnValue([
            'file.nes',
            'plans/commit-message-binary/state.json',
            'plans/commit-message-binary/GUIDANCE.md',
            'plans/commit-message-binary/review-log.md',
          ]),
        run: vi.fn().mockReturnValue(''),
      });
      const actual = await commitWithHint.getDiff();
      const expected = 'Binary files added:\n- file.nes';
      expect(actual).toEqual(expected);
    });
  });
});
