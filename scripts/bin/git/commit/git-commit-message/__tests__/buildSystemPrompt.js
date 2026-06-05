import { __, buildSystemPrompt } from '../buildSystemPrompt.js';

const template = 'Step 1 content\n{{COMMIT_HINT}}\nStep 2 content';

describe('buildSystemPrompt', () => {
  it('when hint is null, returns prompt without hint instruction', async () => {
    vi.spyOn(__, 'readTemplate').mockReturnValue(template);
    vi.spyOn(__, 'getHint').mockReturnValue(null);

    const actual = await buildSystemPrompt();

    expect(actual).not.toContain('hint');
    expect(actual).toContain('Step 1 content');
    expect(actual).toContain('Step 2 content');
  });

  it('when hint is a string, returns prompt with hint instruction and content', async () => {
    const hint = 'feat(scope): my change';
    vi.spyOn(__, 'readTemplate').mockReturnValue(template);
    vi.spyOn(__, 'getHint').mockReturnValue(hint);

    const actual = await buildSystemPrompt();

    expect(actual).toContain('The following hint');
    expect(actual).toContain(hint);
  });
});
