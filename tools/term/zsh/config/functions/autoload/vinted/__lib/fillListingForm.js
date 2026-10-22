import { _, pMap } from 'golgoth';
import { firostError } from 'firost';
import { findField } from './findField.js';
import { waitForLocator } from './waitForLocator.js';
import { writeClipboard } from './writeClipboard.js';

export let __;

const COOKIE_TIMEOUT_IN_MS = 3000;
const PAUSE_RANGE_IN_MS = [400, 1200];
const TYPING_DELAY_IN_MS = 25;
const COOKIE_BUTTON = '#onetrust-accept-btn-handler';
const CONDITION_RADIOS = {
  'New with tags': 6,
  'New without tags': 1,
  'Very good': 2,
  Good: 3,
  Satisfactory: 4,
};
const PARCEL_SIZE_CELLS = {
  Small: 1,
  Medium: 2,
  Large: 3,
};

/**
 * Fill the Vinted listing form, without publishing it
 * The page must already show the listing form of a logged-in session. Stops
 * with an error as soon as a form field is missing.
 * @param {object} page - Playwright page showing the listing form
 * @param {object} listing - Listing returned by parseListing
 * @returns {Promise<object[]>} Duration of each step, as { step, durationInMs }
 */
export async function fillListingForm(page, listing) {
  const timings = [];
  const run = (step, action) => __.timed(timings, step, action);

  await run('cookies', () => __.acceptCookies(page));

  // A partial listing, like an update, only fills the fields it has
  const { photos, title, description, category, isbn, language } = listing;
  const { condition, price, parcelSize, colours, brand } = listing;
  const { platform, rating } = listing;
  if (photos) {
    await run('photos', () => __.setPhotos(page, photos));
  }
  if (title) {
    await run('title', () => __.pasteIn(page, 'title--input', title));
  }
  if (description) {
    await run('description', () =>
      __.pasteIn(page, 'description--input', description),
    );
  }
  if (category) {
    await run('category', () => __.pickCategory(page, category));
  }
  // Only the Books categories have an ISBN and a language. An update without
  // category keeps them, as it edits a listing that already has them.
  const hasBookFields = !category || _.includes(category, 'Books');
  if (isbn && hasBookFields) {
    await run('isbn', () => __.pasteIn(page, 'isbn--input', isbn));
  }
  if (language && hasBookFields) {
    await run('language', () => __.pickLanguage(page, language));
  }
  if (condition) {
    await run('condition', () => __.pickCondition(page, condition));
  }
  if (platform) {
    await run('platform', () => __.pickPlatform(page, platform));
  }
  if (rating) {
    await run('rating', () => __.pickRating(page, rating));
  }
  if (brand) {
    await run('brand', () => __.pickBrand(page, brand));
  }
  if (colours) {
    await run('colours', () => __.pickColours(page, colours));
  }
  if (price !== undefined) {
    await run('price', () =>
      __.typeIn(page, 'price-input--input', __.formatPrice(price)),
    );
  }
  if (parcelSize) {
    await run('parcelSize', () => __.pickParcelSize(page, parcelSize));
  }
  return timings;
}

__ = {
  /**
   * Run an action and record how long it took
   * @param {object[]} timings - List to add { step, durationInMs } to
   * @param {string} step - Name of the step
   * @param {Function} action - Async action to run
   */
  async timed(timings, step, action) {
    const start = performance.now();
    await action();
    timings.push({ step, durationInMs: Math.round(performance.now() - start) });
  },

  /**
   * Wait a random human-like delay
   * @param {object} page - Playwright page
   */
  async pause(page) {
    await page.waitForTimeout(_.random(...PAUSE_RANGE_IN_MS));
  },

  /**
   * Accept the cookie banner when it covers the form
   * @param {object} page - Playwright page
   */
  async acceptCookies(page) {
    const button = page.locator(COOKIE_BUTTON);
    try {
      await button.waitFor({ timeout: COOKIE_TIMEOUT_IN_MS });
    } catch {
      // No banner, nothing to accept
      return;
    }
    await button.click();
    await __.pause(page);
  },

  /**
   * Upload the photos
   * @param {object} page - Playwright page
   * @param {string[]} photos - Absolute photo paths
   */
  async setPhotos(page, photos) {
    // The file input is hidden, so it only needs to be attached
    const input = await findField(page, 'add-photos-input', 'attached');
    await input.setInputFiles(photos);
    await __.pause(page);
  },

  /**
   * Type a text in a form field
   * @param {object} page - Playwright page
   * @param {string} testId - data-testid of the field
   * @param {string} text - Text to type
   */
  async typeIn(page, testId, text) {
    const input = await findField(page, testId);
    await input.click();
    // Replace what the field already holds, as an update does
    await page.keyboard.press('Control+A');
    await input.pressSequentially(text, { delay: TYPING_DELAY_IN_MS });
    await __.pause(page);
  },

  /**
   * Paste a text in a form field, through the clipboard
   * Fails when the field does not hold the text afterwards. There is no typing
   * fallback.
   * @param {object} page - Playwright page
   * @param {string} testId - data-testid of the field
   * @param {string} text - Text to paste
   */
  async pasteIn(page, testId, text) {
    const input = await findField(page, testId);
    await __.writeClipboard(text);
    await input.click();
    // Replace what the field already holds, as an update does
    await page.keyboard.press('Control+A');
    await page.keyboard.press('Control+V');
    await __.pause(page);

    const value = await input.inputValue();
    if (value !== text) {
      throw firostError(
        'VINTED_PASTE_FAILED',
        `Pasting in "${testId}" failed, the field does not hold the expected text`,
      );
    }
  },

  /**
   * Walk the category picker, one label per level
   * @param {object} page - Playwright page
   * @param {string[]} labels - Category labels, from the root to the leaf
   */
  async pickCategory(page, labels) {
    const leaf = _.last(labels);

    // Vinted suggests a category from the title and description, and may have
    // set it already
    if ((await __.readCategory(page)) === leaf) {
      return;
    }

    await __.openCategoryPicker(page);

    // Each level opens only after the previous click, so one at a time. Vinted
    // can set the category by itself in the middle of the walk, which closes
    // the picker.
    await pMap(
      labels,
      async (label) => {
        if ((await __.readCategory(page)) === leaf) {
          return;
        }
        await __.pickCategoryLevel(page, label);
      },
      { concurrency: 1 },
    );
    await __.closeCategoryPicker(page);
  },

  /**
   * Close the category picker when it is still open
   * Vinted can set the category itself while the picker is open, and leaves it
   * covering the fields below.
   * @param {object} page - Playwright page
   */
  async closeCategoryPicker(page) {
    const content = page.getByTestId('catalog-select-dropdown-content').first();
    if (await content.isVisible()) {
      await page.keyboard.press('Escape');
      await __.pause(page);
    }
  },

  /**
   * Open the category picker
   * @param {object} page - Playwright page
   */
  async openCategoryPicker(page) {
    const picker = await findField(page, 'catalog-select-dropdown-input');
    await picker.click();
    await __.pause(page);
  },

  /**
   * Read the category currently shown in the category field
   * @param {object} page - Playwright page
   * @returns {Promise<string>} Label of the category, empty when none is set
   */
  async readCategory(page) {
    const picker = await findField(page, 'catalog-select-dropdown-input');
    return await picker.inputValue();
  },

  /**
   * Click one label of the category picker
   * @param {object} page - Playwright page
   * @param {string} label - Label to click
   */
  async pickCategoryLevel(page, label) {
    const list = await findField(page, 'category-list');
    const item = await waitForLocator(
      list
        .locator('li')
        .filter({ has: page.getByText(label, { exact: true }) }),
      `Category "${label}" not found in the category picker`,
    );
    await item.click();
    await __.pause(page);
  },

  /**
   * Select the book language, once the ISBN field makes it appear
   * @param {object} page - Playwright page
   * @param {string} language - Language label, in English (e.g. "French")
   */
  async pickLanguage(page, language) {
    const picker = await findField(
      page,
      'isbn-language_book-single-list_search-input',
    );
    await picker.click();
    await __.pause(page);

    const list = await findField(
      page,
      'isbn-language_book-single-list_search-content',
    );
    const option = await waitForLocator(
      list.getByText(language, { exact: true }),
      `Language "${language}" not found in the language picker`,
    );
    await option.click();
    await __.pause(page);
  },

  /**
   * Select the condition radio
   * @param {object} page - Playwright page
   * @param {string} condition - One of the five English condition labels
   */
  async pickCondition(page, condition) {
    const container = await findField(
      page,
      'category-condition-single-list-input',
    );
    await container.click();
    await __.pause(page);

    const radio = await findField(
      page,
      `condition-radio-${CONDITION_RADIOS[condition]}`,
    );
    await radio.click();
    await __.pause(page);
  },

  /**
   * Select the video game platform, unless Vinted already suggested it
   * @param {object} page - Playwright page
   * @param {string} platform - Platform label (e.g. "Sega Dreamcast")
   */
  async pickPlatform(page, platform) {
    const picker = await findField(
      page,
      'category-video_game_platform-single-list_search-input',
    );
    if ((await picker.inputValue()) === platform) {
      return;
    }
    await picker.click();
    await __.pause(page);

    const list = await findField(
      page,
      'category-video_game_platform-single-list_search-content',
    );
    const option = await waitForLocator(
      list.getByText(platform, { exact: true }),
      `Platform "${platform}" not found in the platform picker`,
    );
    await option.click();
    await __.pause(page);
  },

  /**
   * Select the content rating of a video game
   * @param {object} page - Playwright page
   * @param {string} rating - Rating label (e.g. "PEGI 12", "Unspecified")
   */
  async pickRating(page, rating) {
    const picker = await findField(
      page,
      'category-video_game_ratings-single-list-input',
    );
    await picker.click();
    await __.pause(page);

    const list = await findField(
      page,
      'category-video_game_ratings-single-list-content',
    );
    const option = await waitForLocator(
      list.getByText(rating, { exact: true }),
      `Rating "${rating}" not found in the rating picker`,
    );
    await option.click();
    await __.pause(page);
  },

  /**
   * Select the brand, for the categories that ask for it
   * @param {object} page - Playwright page
   * @param {string} brand - Brand label (e.g. "Inconnu" when it has none)
   */
  async pickBrand(page, brand) {
    const picker = await findField(page, 'brand-select-dropdown-input');
    await picker.click();
    await __.pause(page);

    const option = await waitForLocator(
      page.getByText(brand, { exact: true }),
      `Brand "${brand}" not found in the brand picker`,
    );
    await option.click();
    await __.pause(page);
  },

  /**
   * Select the colours, for the categories that ask for them
   * @param {object} page - Playwright page
   * @param {string[]} colours - Colour labels in English (e.g. "Multi"), at most two
   */
  async pickColours(page, colours) {
    const picker = await findField(page, 'color-select-dropdown-input');
    await picker.click();
    await __.pause(page);

    // One at a time, the list may re-render after each click
    await pMap(
      colours,
      async (colour) => {
        const option = await waitForLocator(
          page
            .locator('[data-testid^="color-"]')
            .filter({ hasText: new RegExp(`^${colour}$`) }),
          `Colour "${colour}" not found in the colour picker`,
        );
        await option.click();
        await __.pause(page);
      },
      { concurrency: 1 },
    );
    await page.keyboard.press('Escape');
    await __.pause(page);
  },

  /**
   * Select the parcel size
   * The size cells only show once the category is set, so this runs after it.
   * @param {object} page - Playwright page
   * @param {string} parcelSize - One of Small, Medium or Large
   */
  async pickParcelSize(page, parcelSize) {
    const cell = await findField(
      page,
      `${PARCEL_SIZE_CELLS[parcelSize]}-package-size--cell`,
    );
    await cell.click();
    await __.pause(page);
  },

  /**
   * Format a price the way the French form expects it
   * @param {number} price - Price in euros
   * @returns {string} Price with a decimal comma
   */
  formatPrice(price) {
    return String(price).replace('.', ',');
  },

  writeClipboard,
};
