import Gilmore from 'gilmore';
import { commitWithoutHint } from '../commitWithoutHint.js';

vi.mock('gilmore', () => ({ default: vi.fn() }));

describe('commitWithoutHint', () => {
  describe('getDiff', () => {
    it.each([
      {
        title: 'binary-only staged files → binary fallback message',
        stagedFiles: ['game.nes'],
        diffs: { 'game.nes': '' },
        expected: 'Binary files added:\n- game.nes',
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
      const actual = await commitWithoutHint.getDiff();
      expect(actual).toEqual(expected);
    });

    it('excludes yarn.lock from staged files', async () => {
      const mockRun = vi.fn().mockReturnValue('diff text');
      Gilmore.mockReturnValue({
        stagedFiles: vi.fn().mockReturnValue(['yarn.lock', 'src/index.js']),
        run: mockRun,
      });
      await commitWithoutHint.getDiff();
      expect(mockRun).not.toHaveBeenCalledWith('diff --cached -- yarn.lock');
      expect(mockRun).toHaveBeenCalledWith('diff --cached -- src/index.js');
    });
  });
});
