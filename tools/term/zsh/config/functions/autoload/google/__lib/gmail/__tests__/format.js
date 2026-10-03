import stringWidth from 'string-width';
import { __, gmailFormat } from '../format.js';

describe('gmailFormat', () => {
  const message = {
    id: 'a1',
    from: 'Alice Martin <alice@example.com>',
    subject: 'Quarterly report',
    date: 'Fri, 03 Oct 2026 21:26:59 +0200',
    snippet: 'Please find the report attached',
  };

  beforeEach(() => {
    vi.spyOn(__, 'readColors').mockReturnValue({});
  });

  describe('rows', () => {
    it('renders one row per message', async () => {
      const messages = [
        { ...message, subject: 'First' },
        { ...message, subject: 'Second' },
        { ...message, subject: 'Third' },
      ];

      const actual = (await gmailFormat(messages, { width: 200 })).split('\n');

      expect(actual).toHaveLength(3);
      expect(actual[0]).toContain('First');
      expect(actual[1]).toContain('Second');
      expect(actual[2]).toContain('Third');
    });

    it('shows a short date, the sender name and the subject', async () => {
      const actual = await gmailFormat([message], { width: 200 });

      expect(actual).toMatch(
        /^\d{2}\/\d{2} \d{2}:\d{2} {2}Alice Martin {2,}Quarterly report$/,
      );
      expect(actual).not.toContain('alice@example.com');
    });

    it('does not show the snippet', async () => {
      const actual = await gmailFormat([message], { width: 200 });

      expect(actual).not.toContain('Please find the report attached');
    });

    it('keeps the raw sender when it has no display name', async () => {
      const actual = await gmailFormat(
        [{ ...message, from: 'bob@example.com' }],
        { width: 200 },
      );

      expect(actual).toContain('bob@example.com');
    });

    it('keeps rows on a single line', async () => {
      const actual = await gmailFormat([{ ...message, subject: 'Hel\nlo' }], {
        width: 200,
      });

      expect(actual.split('\n')).toHaveLength(1);
    });
  });

  describe('width', () => {
    it.each([60, 80, 120])('truncates rows to %i columns', async (width) => {
      const longMessage = {
        ...message,
        from: 'A very long sender name that goes on <a@example.com>',
        subject: 'A very long subject '.repeat(10),
      };

      const actual = await gmailFormat([longMessage, longMessage], { width });

      actual.split('\n').forEach((row) => {
        expect(stringWidth(row)).toBeLessThanOrEqual(width);
      });
    });

    it('marks a truncated subject with a single ellipsis character', async () => {
      const actual = await gmailFormat(
        [{ ...message, subject: 'word '.repeat(100) }],
        { width: 80 },
      );

      expect(actual.endsWith('…')).toBe(true);
      expect(actual).not.toContain('...');
    });

    it('does not end rows with padding', async () => {
      const actual = await gmailFormat([message], { width: 200 });

      expect(actual).toEqual(actual.trimEnd());
    });

    it.each([
      { title: 'special characters', special: 'Events 𝘣𝘺 La Cantine' },
      { title: 'wide characters', special: 'Cheese 🧀 Night' },
    ])('aligns the subject when the sender has $title', async ({ special }) => {
      const messages = [
        { ...message, from: special, subject: 'Special' },
        { ...message, from: 'Plain ascii sender', subject: 'Regular' },
      ];

      const actual = (await gmailFormat(messages, { width: 200 })).split('\n');

      const offsets = [
        stringWidth(actual[0].slice(0, actual[0].indexOf('Special'))),
        stringWidth(actual[1].slice(0, actual[1].indexOf('Regular'))),
      ];
      expect(offsets).toHaveProperty('0', offsets[1]);
    });
  });

  describe('colors', () => {
    beforeEach(() => {
      vi.spyOn(__, 'readColors').mockReturnValue({
        'gmail-date': { ansi: 166 },
        'gmail-author': { ansi: 35 },
        'gmail-subject': { ansi: 77 },
      });
    });

    it('colors the date, sender and subject with the design system colors', async () => {
      const actual = await gmailFormat([message], { width: 200 });

      expect(actual).toContain('\u001B[38;5;166m');
      expect(actual).toContain('\u001B[38;5;35mAlice Martin');
      expect(actual).toContain('\u001B[38;5;77mQuarterly report');
    });

    it('keeps the visible layout when colored', async () => {
      const colored = await gmailFormat([message], { width: 200 });
      vi.spyOn(__, 'readColors').mockReturnValue({});
      const plain = await gmailFormat([message], { width: 200 });

      const actual = colored
        .split('\u001B[0m')
        .join('')
        .split('\u001B[38;5;166m')
        .join('')
        .split('\u001B[38;5;35m')
        .join('')
        .split('\u001B[38;5;77m')
        .join('');
      expect(actual).toEqual(plain);
    });
  });

  describe('empty inbox', () => {
    it('prints a clear message', async () => {
      const actual = await gmailFormat([], { width: 80 });

      expect(actual).toEqual('No mails in the inbox.');
    });
  });
});

describe('gmailFormat readColors', () => {
  it('reads the design system color definitions', async () => {
    const actual = await __.readColors();

    expect(actual).toHaveProperty('gmail-date.ansi', expect.any(Number));
    expect(actual).toHaveProperty('gmail-author.ansi', expect.any(Number));
    expect(actual).toHaveProperty('gmail-subject.ansi', expect.any(Number));
  });
});
