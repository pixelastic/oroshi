import { listOrders } from '../listOrders.js';

describe('listOrders', () => {
  const since = new Date('2026-10-17T12:00:00.000Z');
  const conversations = [
    {
      id: 'recent-order',
      conversation_type: 'order',
      last_message: { created_at: '2026-10-22T10:00:00Z' },
      data: { inventory_items: [{ id: '20', title: 'Twenty' }] },
    },
    {
      id: 'bundle',
      conversation_type: 'order',
      last_message: { created_at: '2026-10-21T10:00:00Z' },
      data: {
        inventory_items: [
          { id: '10', title: 'Ten' },
          { id: '11', title: 'Eleven' },
        ],
      },
    },
    {
      id: 'offer',
      conversation_type: 'inquiry',
      last_message: { created_at: '2026-10-22T10:00:00Z' },
      data: { inventory_items: [{ id: '30', title: 'Thirty' }] },
    },
    {
      id: 'old-order',
      conversation_type: 'order',
      last_message: { created_at: '2026-10-10T10:00:00Z' },
      data: { inventory_items: [{ id: '40', title: 'Forty' }] },
    },
    {
      id: 'empty-order',
      conversation_type: 'order',
      last_message: { created_at: '2026-10-22T10:00:00Z' },
      data: { inventory_items: [] },
    },
  ];

  it('keeps the recent orders, named after their first item', () => {
    const actual = listOrders(conversations, { since });

    expect(actual).toEqual([
      {
        name: '20.pdf',
        conversationId: 'recent-order',
        items: [{ id: '20', title: 'Twenty' }],
      },
      {
        name: '10.pdf',
        conversationId: 'bundle',
        items: [
          { id: '10', title: 'Ten' },
          { id: '11', title: 'Eleven' },
        ],
      },
    ]);
  });
});
