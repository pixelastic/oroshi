import { consoleError } from 'firost';
import { callApi } from '../callApi.js';

vi.mock('firost', () => ({ consoleError: vi.fn() }));

describe('callApi', () => {
  let mockFetch;
  let mockExit;

  beforeEach(() => {
    mockFetch = vi.fn();
    vi.stubGlobal('fetch', mockFetch);
    mockExit = vi.spyOn(process, 'exit').mockImplementation(() => {
      throw new Error('process.exit');
    });
    process.env.ANTHROPIC_API_KEY = 'test-key';
  });

  describe('empty diff guard', () => {
    it.each([
      { title: 'empty string', diff: '' },
      { title: 'whitespace-only', diff: '   \n  ' },
    ])('exits with code 1 when diff is $title', async ({ diff }) => {
      try {
        await callApi({ prompt: 'test', diff });
      } catch {
        // expected: mocked process.exit throws
      }
      expect(mockExit).toHaveBeenCalledWith(1);
      expect(mockFetch).not.toHaveBeenCalled();
    });

    it('prints a message mentioning "empty diff"', async () => {
      try {
        await callApi({ prompt: 'test', diff: '' });
      } catch {
        // expected: mocked process.exit throws
      }
      expect(consoleError).toHaveBeenCalledWith(
        expect.stringContaining('Empty diff'),
      );
    });
  });

  describe('missing API key', () => {
    it('exits with code 1 when ANTHROPIC_API_KEY is not set', async () => {
      delete process.env.ANTHROPIC_API_KEY;
      try {
        await callApi({ prompt: 'test', diff: 'some diff' });
      } catch {
        // expected: mocked process.exit throws
      }
      expect(mockExit).toHaveBeenCalledWith(1);
    });
  });

  describe('API error response', () => {
    it('exits with code 1 when API returns non-200 status', async () => {
      mockFetch.mockReturnValue({
        ok: false,
        status: 500,
        statusText: 'Internal Server Error',
      });
      try {
        await callApi({ prompt: 'test', diff: 'some diff' });
      } catch {
        // expected: mocked process.exit throws
      }
      expect(mockExit).toHaveBeenCalledWith(1);
    });
  });
});
