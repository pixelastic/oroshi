import { ensureLoggedIn } from '../ensureLoggedIn.js';

describe('ensureLoggedIn', () => {
  /**
   * Build a fake page sitting on a given URL
   * @param {string} url - Current URL of the page
   * @returns {object} Fake page
   */
  function pageAt(url) {
    return { url: () => url };
  }

  it('passes when the page shows the listing form', async () => {
    const page = pageAt('https://www.vinted.fr/items/new');

    let actual = null;
    try {
      await ensureLoggedIn(page);
    } catch (error) {
      actual = error;
    }

    expect(actual).toBeNull();
  });

  it.each([
    { input: 'https://www.vinted.fr/member/register/select_type' },
    { input: 'https://www.vinted.fr/member/login' },
  ])('throws an error naming vinted-login on $input', async ({ input }) => {
    let actual = null;
    try {
      await ensureLoggedIn(pageAt(input));
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'VINTED_NOT_LOGGED_IN');
    expect(actual).toHaveProperty(
      'message',
      'Vinted session expired, run vinted-login to log in again',
    );
  });
});
