import stringWidth from 'string-width';
import { __, gmailFormat } from '../format.js';

describe('gmailFormat', () => {
  const thread = {
    threadId: 't1',
    unread: false,
    date: '2026-10-03T19:26:59.000Z',
    count: 1,
    authors: ['Alice Martin'],
    subject: 'Quarterly report',
    snippet: 'Please find the report attached',
  };

  beforeEach(() => {
    vi.spyOn(__, 'readColors').mockReturnValue({});
    vi.spyOn(__, 'readIcons').mockReturnValue({ 'gmail-unread': '*' });
  });

  describe('rows', () => {
    it('renders one row per thread', async () => {
      const threads = [
        { ...thread, subject: 'First' },
        { ...thread, subject: 'Second' },
        { ...thread, subject: 'Third' },
      ];

      const actual = (await gmailFormat(threads, { width: 200 })).split('\n');

      expect(actual).toHaveLength(3);
      expect(actual[0]).toContain('First');
      expect(actual[1]).toContain('Second');
      expect(actual[2]).toContain('Third');
    });

    it('shows the unread marker, the date, the author and the subject', async () => {
      const actual = await gmailFormat([{ ...thread, unread: true }], {
        width: 200,
      });

      expect(actual).toMatch(
        /^\* {2}\d{2}\/\d{2} \d{2}:\d{2} {2,}Alice Martin {2,}Quarterly report$/,
      );
    });

    it('shows a blank instead of the marker for a read thread', async () => {
      const actual = await gmailFormat([thread], { width: 200 });

      expect(actual).not.toContain('*');
      expect(actual).toMatch(/^ {3}\d{2}\/\d{2} /);
    });

    describe('with a UTC timezone', () => {
      beforeEach(() => {
        vi.stubEnv('TZ', 'UTC');
      });

      afterEach(() => {
        vi.unstubAllEnvs();
      });

      it('formats the date from the ISO date', async () => {
        const actual = await gmailFormat([thread], { width: 200 });

        expect(actual).toContain('10/03 19:26');
      });
    });

    it('leaves the date blank when it is invalid', async () => {
      const actual = await gmailFormat([{ ...thread, date: '' }], {
        width: 200,
      });

      expect(actual).toMatch(/^ {3} {11} {2}/);
    });

    it('does not show the snippet', async () => {
      const actual = await gmailFormat([thread], { width: 200 });

      expect(actual).not.toContain('Please find the report attached');
    });

    it('keeps rows on a single line', async () => {
      const actual = await gmailFormat([{ ...thread, subject: 'Hel\nlo' }], {
        width: 200,
      });

      expect(actual.split('\n')).toHaveLength(1);
    });
  });

  describe('count', () => {
    it.each([
      {
        title: 'leaves the count blank for a single message',
        count: 1,
        expected: /\d{2}:\d{2} {3,}Alice Martin/,
      },
      {
        title: 'shows the count for several messages',
        count: 3,
        expected: /\d{2}:\d{2} {2}3 {2}Alice Martin/,
      },
    ])('$title', async ({ count, expected }) => {
      const actual = await gmailFormat([{ ...thread, count }], {
        width: 200,
      });

      expect(actual).toMatch(expected);
    });

    it('keeps the count right-aligned across rows', async () => {
      const threads = [
        { ...thread, count: 3, subject: 'Few' },
        { ...thread, count: 12, subject: 'Many' },
        { ...thread, count: 1, subject: 'Single' },
      ];

      const actual = (await gmailFormat(threads, { width: 200 })).split('\n');

      expect(actual[0]).toMatch(/\d{2}:\d{2} {3}3 {2}Alice Martin/);
      expect(actual[1]).toMatch(/\d{2}:\d{2} {2}12 {2}Alice Martin/);
      expect(actual[2]).toMatch(/\d{2}:\d{2} {6}Alice Martin/);
    });

    it('keeps the authors aligned across rows', async () => {
      const threads = [
        { ...thread, count: 12, subject: 'Many' },
        { ...thread, count: 1, subject: 'Single' },
      ];

      const actual = (await gmailFormat(threads, { width: 200 })).split('\n');

      expect(actual[0].indexOf('Alice')).toEqual(actual[1].indexOf('Alice'));
    });
  });

  describe('authors', () => {
    it('joins the authors with a comma and a space', async () => {
      const actual = await gmailFormat(
        [{ ...thread, authors: ['Alice Martin', 'Bob Stone'] }],
        { width: 200 },
      );

      expect(actual).toContain('Alice Martin, Bob Stone');
    });
  });

  describe('width', () => {
    const longThread = {
      ...thread,
      unread: true,
      count: 25,
      authors: ['A very long author name', 'Another very long author name'],
      subject: 'A very long subject '.repeat(10),
    };

    it.each([60, 80, 120])('truncates rows to %i columns', async (width) => {
      const actual = await gmailFormat([longThread, longThread], { width });

      actual.split('\n').forEach((row) => {
        expect(stringWidth(row)).toBeLessThanOrEqual(width);
      });
    });

    it('truncates long authors with an ellipsis and keeps the subject visible', async () => {
      const actual = await gmailFormat(
        [{ ...longThread, subject: 'Visible subject' }],
        { width: 80 },
      );

      expect(actual).toMatch(/author name, An…\s+Visible subject$/);
    });

    it('marks a truncated subject with a single ellipsis character', async () => {
      const actual = await gmailFormat(
        [{ ...thread, subject: 'word '.repeat(100) }],
        { width: 80 },
      );

      expect(actual.endsWith('…')).toBe(true);
      expect(actual).not.toContain('...');
    });

    it('does not end rows with padding', async () => {
      const actual = await gmailFormat([thread], { width: 200 });

      expect(actual).toEqual(actual.trimEnd());
    });

    it.each([
      { title: 'special characters', special: 'Events 𝘣𝘺 La Cantine' },
      { title: 'wide characters', special: 'Cheese 🧀 Night' },
    ])('aligns the subject when the author has $title', async ({ special }) => {
      const threads = [
        { ...thread, authors: [special], subject: 'Special' },
        { ...thread, authors: ['Plain ascii author'], subject: 'Regular' },
      ];

      const actual = (await gmailFormat(threads, { width: 200 })).split('\n');

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

    it('colors the date, authors and subject with the design system colors', async () => {
      const actual = await gmailFormat([thread], { width: 200 });

      expect(actual).toContain('\u001B[38;5;166m');
      expect(actual).toContain('\u001B[38;5;35mAlice Martin');
      expect(actual).toContain('\u001B[38;5;77mQuarterly report');
    });

    it('keeps the visible layout when colored', async () => {
      const threads = [{ ...thread, unread: true, count: 4 }];
      const colored = await gmailFormat(threads, { width: 200 });
      vi.spyOn(__, 'readColors').mockReturnValue({});
      const plain = await gmailFormat(threads, { width: 200 });

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

describe('gmailFormat readIcons', () => {
  it('reads the unread marker from the design system icons', async () => {
    const actual = await __.readIcons();

    expect(actual).toHaveProperty('gmail-unread', '●');
  });
});
