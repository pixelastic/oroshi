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
      {
        title: 'rename-only staged files → rename fallback block',
        stagedFilesWithStatus: [
          {
            name: 'new/path.js',
            status: 'renamed',
            from: 'old/path.js',
            similarity: 100,
          },
        ],
        diffs: {},
        expected: 'Files renamed:\n- old/path.js \u2192 new/path.js',
      },
      {
        title: 'mixed rename + text → diff + rename block',
        stagedFilesWithStatus: [
          { name: 'src/index.js', status: 'modified' },
          {
            name: 'new/path.js',
            status: 'renamed',
            from: 'old/path.js',
            similarity: 100,
          },
        ],
        diffs: { 'src/index.js': 'diff text' },
        expected:
          'diff text\n\nFiles renamed:\n- old/path.js \u2192 new/path.js',
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

    it('excludes yarn.lock from rename processing', async () => {
      Gilmore.mockReturnValue({
        stagedFilesWithStatus: vi.fn().mockReturnValue([
          {
            name: 'yarn.lock',
            status: 'renamed',
            from: 'old-yarn.lock',
            similarity: 100,
          },
          {
            name: 'new/path.js',
            status: 'renamed',
            from: 'old/path.js',
            similarity: 100,
          },
        ]),
        run: vi.fn().mockReturnValue(''),
      });
      const actual = await commitWithoutHint.getDiff();
      expect(actual).toEqual(
        'Files renamed:\n- old/path.js \u2192 new/path.js',
      );
    });
  });
});
