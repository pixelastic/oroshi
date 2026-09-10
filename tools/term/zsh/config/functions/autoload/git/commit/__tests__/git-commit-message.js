import { __, main } from '../__lib/git-commit-message.js';

describe('git-commit-message', () => {
  beforeEach(() => {
    vi.spyOn(__, 'init').mockImplementation(() => {});
    vi.spyOn(__, 'getStrategy').mockReturnValue({
      getPrompt: vi.fn().mockReturnValue('prompt'),
      getDiff: vi.fn().mockReturnValue('some diff'),
    });
    vi.spyOn(__, 'run').mockReturnValue({ stdout: 'feat: message' });
    vi.spyOn(__, 'formatMessage').mockReturnValue('feat: message');
    vi.spyOn(process, 'exit').mockImplementation((code) => {
      throw new Error(`process.exit(${code})`);
    });
    vi.spyOn(console, 'log').mockImplementation(() => {});
  });

  it('exits non-zero with no stdout when no staged files', async () => {
    vi.spyOn(__, 'getRepo').mockReturnValue({
      stagedFilesWithStatus: vi.fn().mockReturnValue([]),
    });

    let actual = null;
    try {
      await main();
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('message', 'process.exit(1)');
    expect(console.log).not.toHaveBeenCalled();
  });

  it('outputs hardcoded message when only yarn.lock is staged', async () => {
    vi.spyOn(__, 'getRepo').mockReturnValue({
      stagedFilesWithStatus: vi
        .fn()
        .mockReturnValue([{ name: 'yarn.lock', status: 'modified' }]),
    });

    await main();

    expect(console.log).toHaveBeenCalledWith('chore(deps): update yarn.lock');
    expect(__.getStrategy).not.toHaveBeenCalled();
  });
});
