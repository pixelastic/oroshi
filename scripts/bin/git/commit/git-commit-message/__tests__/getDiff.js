import { getRepo } from '../config.js';
import { getDiff } from '../getDiff.js';

vi.mock('../config.js', () => ({ getRepo: vi.fn() }));

describe('getDiff', () => {
  let mockRun;
  let mockStagedFilesWithStatus;

  beforeEach(() => {
    mockRun = vi.fn();
    mockStagedFilesWithStatus = vi.fn();
    getRepo.mockReturnValue({
      stagedFilesWithStatus: mockStagedFilesWithStatus,
      run: mockRun,
    });
  });

  describe('rename-only', () => {
    it('returns rename fallback block when all files are 100% renames', async () => {
      mockStagedFilesWithStatus.mockReturnValue([
        {
          name: 'new/path.js',
          status: 'renamed',
          from: 'old/path.js',
          similarity: 100,
        },
      ]);

      const actual = await getDiff([]);

      expect(actual).toEqual(
        'Files renamed:\n- old/path.js \u2192 new/path.js',
      );
      expect(mockRun).not.toHaveBeenCalled();
    });
  });

  describe('content-only', () => {
    it('returns raw diff when no renames', async () => {
      mockStagedFilesWithStatus.mockReturnValue([
        { name: 'src/app.js', status: 'modified' },
      ]);
      mockRun.mockReturnValue('diff --git a/src/app.js');

      const actual = await getDiff([]);

      expect(actual).toEqual('diff --git a/src/app.js');
    });
  });

  describe('binary-only', () => {
    it('returns binary fallback when diffs are empty', async () => {
      mockStagedFilesWithStatus.mockReturnValue([
        { name: 'image.png', status: 'added' },
      ]);
      mockRun.mockReturnValue('');

      const actual = await getDiff([]);

      expect(actual).toEqual('Binary files added:\n- image.png');
    });
  });

  describe('mixed scenarios', () => {
    it('returns content diff + rename block', async () => {
      mockStagedFilesWithStatus.mockReturnValue([
        { name: 'src/app.js', status: 'modified' },
        { name: 'new.js', status: 'renamed', from: 'old.js', similarity: 100 },
      ]);
      mockRun.mockReturnValue('diff content');

      const actual = await getDiff([]);

      expect(actual).toEqual(
        'diff content\n\nFiles renamed:\n- old.js \u2192 new.js',
      );
    });

    it('returns rename block + binary block', async () => {
      mockStagedFilesWithStatus.mockReturnValue([
        { name: 'new.js', status: 'renamed', from: 'old.js', similarity: 100 },
        { name: 'image.png', status: 'added' },
      ]);
      mockRun.mockReturnValue('');

      const actual = await getDiff([]);

      expect(actual).toEqual(
        'Files renamed:\n- old.js \u2192 new.js\n\nBinary files added:\n- image.png',
      );
    });

    it('returns content + rename block + binary block', async () => {
      mockStagedFilesWithStatus.mockReturnValue([
        { name: 'src/app.js', status: 'modified' },
        { name: 'new.js', status: 'renamed', from: 'old.js', similarity: 100 },
        { name: 'image.png', status: 'added' },
      ]);
      // First call for modified file returns diff, second for binary returns empty
      mockRun.mockReturnValueOnce('diff content').mockReturnValueOnce('');

      const actual = await getDiff([]);

      expect(actual).toEqual(
        'diff content\n\nFiles renamed:\n- old.js \u2192 new.js\n\nBinary files added:\n- image.png',
      );
    });
  });

  describe('renames with < 100% similarity', () => {
    it('diffs files with similarity below 100', async () => {
      mockStagedFilesWithStatus.mockReturnValue([
        { name: 'new.js', status: 'renamed', from: 'old.js', similarity: 80 },
      ]);
      mockRun.mockReturnValue('diff of renamed file');

      const actual = await getDiff([]);

      expect(actual).toEqual('diff of renamed file');
    });
  });

  describe('filtering', () => {
    it('excludes files from all categories', async () => {
      mockStagedFilesWithStatus.mockReturnValue([
        { name: 'keep.js', status: 'modified' },
        { name: 'skip.js', status: 'modified' },
        { name: 'new.js', status: 'renamed', from: 'old.js', similarity: 100 },
        {
          name: 'skip-rename.js',
          status: 'renamed',
          from: 'old-skip.js',
          similarity: 100,
        },
      ]);
      mockRun.mockReturnValue('diff keep.js');

      const actual = await getDiff(['skip.js', 'skip-rename.js']);

      expect(actual).toEqual(
        'diff keep.js\n\nFiles renamed:\n- old.js \u2192 new.js',
      );
    });
  });
});
