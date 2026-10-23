import { _ } from 'golgoth';

/**
 * List the orders of the inbox that are recent enough
 * An order is named after its first item, so a bundle has one label.
 * Offers are not orders and never have a label. An order with no item is
 * ignored.
 * @param {object[]} conversations - Conversations from the inbox API
 * @param {object} options - Options
 * @param {Date} options.since - Oldest last message to keep
 * @returns {object[]} Orders as { name, conversationId, items }, name being the
 * label file name
 */
export function listOrders(conversations, { since }) {
  return _.chain(conversations)
    .filter({ conversation_type: 'order' })
    .filter(({ last_message }) => new Date(last_message.created_at) >= since)
    .map((conversation) => ({
      conversationId: conversation.id,
      items: _.map(conversation.data.inventory_items, ({ id, title }) => ({
        id: String(id),
        title,
      })),
    }))
    .reject(({ items }) => _.isEmpty(items))
    .map(({ conversationId, items }) => ({
      name: `${items[0].id}.pdf`,
      conversationId,
      items,
    }))
    .value();
}
