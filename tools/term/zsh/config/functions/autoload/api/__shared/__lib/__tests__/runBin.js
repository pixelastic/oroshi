import { firostError } from 'firost';
import { runBin } from '../runBin.js';

describe('runBin', () => {
  beforeEach(() => {
    vi.spyOn(console, 'error').mockReturnValue();
    vi.spyOn(process, 'exit').mockReturnValue();
  });

  describe('with a firostError', () => {
    beforeEach(async () => {
      await runBin(() => {
        throw firostError('MAKE_NOPE', 'Something is wrong');
      });
    });

    it('prints CODE: message on stderr', () => {
      expect(console.error).toHaveBeenCalledWith(
        'MAKE_NOPE: Something is wrong',
      );
    });

    it('prints nothing else', () => {
      expect(console.error).toHaveBeenCalledTimes(1);
    });

    it('exits with code 1', () => {
      expect(process.exit).toHaveBeenCalledWith(1);
    });
  });

  it('rethrows an unexpected error with its stack trace', async () => {
    const input = new TypeError('boom');

    let actual = null;
    try {
      await runBin(async () => {
        throw input;
      });
    } catch (error) {
      actual = error;
    }

    expect(actual).toBe(input);
    expect(actual.stack).toContain('TypeError: boom');
    expect(console.error).not.toHaveBeenCalled();
    expect(process.exit).not.toHaveBeenCalled();
  });

  it('does nothing when the function resolves', async () => {
    const input = vi.fn();

    await runBin(input);

    expect(input).toHaveBeenCalledTimes(1);
    expect(console.error).not.toHaveBeenCalled();
    expect(process.exit).not.toHaveBeenCalled();
  });
});
