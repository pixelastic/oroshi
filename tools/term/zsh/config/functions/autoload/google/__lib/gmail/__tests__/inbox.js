import { __ as formatPrivate } from '../format.js';
import { __, gmailInbox } from '../inbox.js';

describe('gmailInbox', () => {
  beforeEach(() => {
    vi.spyOn(formatPrivate, 'readColors').mockReturnValue({});
    vi.spyOn(formatPrivate, 'readIcons').mockReturnValue({
      'gmail-unread': '●',
    });
  });

  it('renders the raw thread lines as a table', async () => {
    const line = [
      't1',
      '1',
      '2026-10-03T19:26:59.000Z',
      '3',
      'Alice Martin▯Bob Stone',
      'Quarterly report',
      'snippet',
    ].join('▮');
    vi.spyOn(__, 'gmailInboxRaw').mockReturnValue([line]);

    const actual = await gmailInbox('pro', { limit: 5, width: 120 });

    expect(__.gmailInboxRaw).toHaveBeenCalledWith('pro', 5);
    expect(actual).toContain('●');
    expect(actual).toContain('Alice Martin, Bob Stone');
    expect(actual).toContain('Quarterly report');
  });

  it('prints the empty message when there are no threads', async () => {
    vi.spyOn(__, 'gmailInboxRaw').mockReturnValue([]);

    const actual = await gmailInbox('pro', { width: 80 });

    expect(actual).toEqual('No mails in the inbox.');
  });
});
