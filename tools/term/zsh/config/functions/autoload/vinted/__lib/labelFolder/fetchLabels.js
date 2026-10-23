import path from 'node:path';
import { _ } from 'golgoth';
import { exists, firostError } from 'firost';
import { listOrders } from './listOrders.js';
import { updateLabelIndex } from './updateLabelIndex.js';
import { writeBinary } from './writeBinary.js';

const INBOX_URL = 'https://www.vinted.fr/inbox';
const INBOX_API_PATTERN = /api\.vinted\.fr\/messaging\/main\/inbox/;
const BUTTON_NAME = /^(Print|Get) shipping label$/;
const BLOCKED_TITLE = /blocked|captcha|datadome/i;
const BUTTON_WAIT_IN_MS = 8000;
const OPEN_WAIT_IN_MS = 5000;
const OPEN_ATTEMPTS = 4;
const SCROLL_WAIT_IN_MS = 4000;
const MAX_STALLS = 3;
const MAX_SCROLLS = 80;
const MIN_PAUSE_IN_MS = 4000;
const MAX_PAUSE_IN_MS = 9000;

export let __;

/**
 * Walk the inbox like a person, order after order, and get the shipping labels
 * - A "Print shipping label" button: the label is saved as <first item id>.pdf
 *   in the labels folder, unless that file exists already.
 * - A "Get shipping label" button: it is clicked, so the label arrives later
 *   as a new message.
 * - Anything else is skipped.
 * Each saved label is recorded in the index of the folder, with its items.
 * A random pause separates two conversations, to stay under the rate limit.
 * The walk stops at the first sign of the anti-bot protection.
 * @param {object} context - Playwright browser context, logged in
 * @param {object} options - Options
 * @param {string} options.labelsDirectory - Folder to save the labels in
 * @param {Date} options.since - Stop at the orders older than this date
 * @param {Function} [options.onProgress] - Called with (status, order) for each
 * order. Status is saved, requested, have, skipped or failed
 * @returns {Promise<object>} Orders by status
 */
export async function fetchLabels(
  context,
  { labelsDirectory, since, onProgress = _.noop },
) {
  const page = context.pages()[0] ?? (await context.newPage());
  const orders = await __.readOrders(page, since);
  const report = {
    saved: [],
    requested: [],
    have: [],
    skipped: [],
    failed: [],
  };

  await _.reduce(
    orders,
    async (previous, order) => {
      await previous;
      const labelPath = path.join(labelsDirectory, order.name);

      // The label is already there, so only the index needs the entry
      if (await exists(labelPath)) {
        await updateLabelIndex(labelsDirectory, __.indexEntry(order));
        report.have.push(order);
        onProgress('have', order);
        return;
      }

      let status = 'failed';
      try {
        status = await __.visit(context, page, order, labelPath);
      } catch (error) {
        if (error.code === 'VINTED_BLOCKED') {
          throw error;
        }
      }
      if (status === 'saved') {
        await updateLabelIndex(labelsDirectory, __.indexEntry(order));
      }
      report[status].push(order);
      onProgress(status, order);
      await page.waitForTimeout(__.pause());
    },
    Promise.resolve(),
  );
  return report;
}

__ = {
  /**
   * Time to wait between two conversations, so it looks like a person
   * @returns {number} Milliseconds
   */
  pause() {
    return _.random(MIN_PAUSE_IN_MS, MAX_PAUSE_IN_MS);
  },

  /**
   * Index entry of an order
   * @param {object} order - Order from listOrders
   * @returns {object} Entry by label file name
   */
  indexEntry(order) {
    return {
      [order.name]: {
        conversationId: order.conversationId,
        items: order.items,
      },
    };
  },

  /**
   * Read the orders of the inbox until the given date
   * The inbox loads 20 conversations per page, as the list is scrolled. The
   * pages the site loads by itself are read, so no extra request is sent.
   * @param {object} page - Playwright page
   * @param {Date} since - Stop at conversations older than this date
   * @returns {Promise<object[]>} Orders from listOrders
   */
  async readOrders(page, since) {
    const conversations = new Map();
    page.on('response', async (response) => {
      if (!INBOX_API_PATTERN.test(response.url()) || !response.ok()) {
        return;
      }
      const body = await response.json().catch(() => ({}));
      _.each(body.conversations, (conversation) =>
        conversations.set(conversation.id, conversation),
      );
    });

    await page.goto(INBOX_URL, { waitUntil: 'load' });
    await page.waitForTimeout(3000);
    await __.ensureNotBlocked(page);
    if (conversations.size === 0) {
      throw firostError(
        'VINTED_INBOX_EMPTY',
        'The inbox did not load, the session may be logged out',
      );
    }

    let stalls = 0;
    for (
      let scroll = 0;
      scroll < MAX_SCROLLS && stalls < MAX_STALLS;
      scroll++
    ) {
      const oldest = _.chain([...conversations.values()])
        .map(({ last_message }) => new Date(last_message.created_at))
        .min()
        .value();
      if (oldest < since) {
        break;
      }

      const before = conversations.size;
      const loaded = page
        .waitForResponse((response) => INBOX_API_PATTERN.test(response.url()), {
          timeout: SCROLL_WAIT_IN_MS,
        })
        .catch(() => null);
      await page.evaluate(() =>
        document.querySelectorAll('*').forEach((element) => {
          if (element.scrollHeight > element.clientHeight + 200) {
            element.scrollTop = element.scrollHeight;
          }
        }),
      );
      await loaded;
      await page.waitForTimeout(500);
      stalls = conversations.size === before ? stalls + 1 : 0;
    }

    return listOrders([...conversations.values()], { since });
  },

  /**
   * Throw when the page is the anti-bot wall
   * @param {object} page - Playwright page
   */
  async ensureNotBlocked(page) {
    if (!BLOCKED_TITLE.test(await page.title())) {
      return;
    }
    throw firostError(
      'VINTED_BLOCKED',
      'Vinted blocked the session, wait a while and solve the captcha in the browser',
    );
  },

  /**
   * Open the conversation of an order, and act on its shipping label button
   * @param {object} context - Playwright browser context
   * @param {object} page - Playwright page
   * @param {object} order - Order from listOrders
   * @param {string} labelPath - Where to save the label
   * @returns {Promise<string>} saved, requested, skipped or failed
   */
  async visit(context, page, order, labelPath) {
    await page.goto(`https://www.vinted.fr/inbox/${order.conversationId}`, {
      waitUntil: 'load',
    });
    await __.ensureNotBlocked(page);

    const button = page.getByRole('button', { name: BUTTON_NAME }).first();
    try {
      await button.waitFor({ timeout: BUTTON_WAIT_IN_MS });
    } catch {
      return 'skipped';
    }

    // The label comes later, so there is nothing to save yet
    if (/^Get/.test(await button.innerText())) {
      await button.click({ timeout: BUTTON_WAIT_IN_MS });
      await page.waitForTimeout(2500);
      return 'requested';
    }

    // The first click is sometimes lost, so click again until something opens
    let opened = null;
    for (let attempt = 0; attempt < OPEN_ATTEMPTS && !opened; attempt++) {
      const next = Promise.race([
        context
          .waitForEvent('page', { timeout: OPEN_WAIT_IN_MS })
          .then((popup) => ({ popup })),
        page
          .waitForEvent('download', { timeout: OPEN_WAIT_IN_MS })
          .then((download) => ({ download })),
      ]).catch(() => null);
      await button.click({ timeout: BUTTON_WAIT_IN_MS });
      opened = await next;
    }
    if (!opened) {
      return 'failed';
    }

    // The popup is a signed link to the PDF, with no protection to cross
    if (opened.download) {
      await opened.download.saveAs(labelPath);
      return 'saved';
    }
    const response = await context.request.get(opened.popup.url());
    await writeBinary(await response.body(), labelPath);
    await opened.popup.close();
    return 'saved';
  },
};
