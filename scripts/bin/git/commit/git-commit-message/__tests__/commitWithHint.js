import { commitWithHint } from '../commitWithHint.js';
import { getRepo } from '../config.js';

vi.mock('../config.js', () => ({ getRepo: vi.fn() }));
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
      getRepo.mockReturnValue({
        stagedFilesWithStatus: vi.fn().mockReturnValue(stagedFilesWithStatus),
        run: vi.fn().mockImplementation((cmd) => diffs[cmd.at(-1)] ?? ''),
      });
      const actual = await commitWithHint.getDiff();
      expect(actual).toEqual(expected);
    });

    it('plan-noise files do not appear in binary fallback', async () => {
      getRepo.mockReturnValue({
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

    it('plan-noise files excluded from rename fallback', async () => {
      getRepo.mockReturnValue({
        stagedFilesWithStatus: vi.fn().mockReturnValue([
          {
            name: 'new/path.js',
            status: 'renamed',
            from: 'old/path.js',
            similarity: 100,
          },
          {
            name: 'plans/commit-message-binary/state.json',
            status: 'renamed',
            from: 'plans/commit-message-binary/old-state.json',
            similarity: 100,
          },
        ]),
        run: vi.fn().mockReturnValue(''),
      });
      const actual = await commitWithHint.getDiff();
      expect(actual).toEqual(
        'Files renamed:\n- old/path.js \u2192 new/path.js',
      );
    });
  });
});
