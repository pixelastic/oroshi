import Gilmore from 'gilmore';
import { commitWithoutHint } from '../commitWithoutHint.js';

vi.mock('gilmore', () => ({ default: vi.fn() }));

describe('commitWithoutHint', () => {
  describe('getDiff', () => {
    it.each([
      {
        title: 'binary-only staged files → binary fallback message',
        stagedFilesWithStatus: [{ name: 'game.nes', status: 'added' }],
        diffs: { 'game.nes': '' },
        expected: 'Binary files added:\n- game.nes',
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
      const actual = await commitWithoutHint.getDiff();
      expect(actual).toEqual(expected);
    });

    it('excludes yarn.lock from staged files', async () => {
      const mockRun = vi.fn().mockReturnValue('diff text');
      Gilmore.mockReturnValue({
        stagedFilesWithStatus: vi.fn().mockReturnValue([
          { name: 'yarn.lock', status: 'modified' },
          { name: 'src/index.js', status: 'modified' },
        ]),
        run: mockRun,
      });
      await commitWithoutHint.getDiff();
      expect(mockRun).not.toHaveBeenCalledWith('diff --cached -M -- yarn.lock');
      expect(mockRun).toHaveBeenCalledWith('diff --cached -M -- src/index.js');
    });
  });
});
