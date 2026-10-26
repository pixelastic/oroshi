import { __, openUrl } from '../openUrl.js';

describe('openUrl', () => {
  beforeEach(() => {
    vi.spyOn(__, 'run').mockReturnValue();
  });

  it('opens the URL in the browser, without waiting for it', async () => {
    await openUrl('https://docs.google.com/document/d/docA/edit');

    expect(__.run).toHaveBeenCalledWith(
      ['xdg-open', 'https://docs.google.com/document/d/docA/edit'],
      { detached: true },
    );
  });
});
