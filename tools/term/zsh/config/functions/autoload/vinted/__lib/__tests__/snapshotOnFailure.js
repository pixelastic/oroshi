import { __, snapshotOnFailure } from '../snapshotOnFailure.js';

describe('snapshotOnFailure', () => {
  let page;
  beforeEach(() => {
    page = { url: () => 'https://www.vinted.fr/items/new' };
    vi.spyOn(__, 'savePage').mockReturnValue('/pages/failed.html');
    vi.spyOn(__, 'consoleError').mockReturnValue();
  });

  it('returns what the action returns, without saving the page', async () => {
    const action = vi.fn().mockReturnValue([{ step: 'title' }]);

    const actual = await snapshotOnFailure(page, action);

    expect(actual).toEqual([{ step: 'title' }]);
    expect(__.savePage).not.toHaveBeenCalled();
  });

  it('saves the page, tells where, and rethrows the same error', async () => {
    const failure = new Error('Category "Fiction" not found');
    const action = vi.fn().mockImplementation(() => {
      throw failure;
    });

    let actual = null;
    try {
      await snapshotOnFailure(page, action);
    } catch (error) {
      actual = error;
    }

    expect(actual).toBe(failure);
    expect(__.savePage).toHaveBeenCalledTimes(1);
    expect(__).toHaveProperty('savePage.mock.calls.0.0', page);
    expect(__.consoleError).toHaveBeenCalledWith(
      expect.stringContaining('/pages/failed.html'),
    );
  });

  it('still rethrows the original error when saving the page fails', async () => {
    __.savePage.mockImplementation(() => {
      throw new Error('browser closed');
    });
    const failure = new Error('Category "Fiction" not found');
    const action = vi.fn().mockImplementation(() => {
      throw failure;
    });

    let actual = null;
    try {
      await snapshotOnFailure(page, action);
    } catch (error) {
      actual = error;
    }

    expect(actual).toBe(failure);
  });
});
