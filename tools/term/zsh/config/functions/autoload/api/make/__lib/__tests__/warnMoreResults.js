import { warnMoreResults } from '../warnMoreResults.js';

describe('warnMoreResults', () => {
  it('prints the notice on stderr', () => {
    vi.spyOn(console, 'error').mockReturnValue();
    vi.spyOn(console, 'log').mockReturnValue();

    warnMoreResults();

    expect(console.error).toHaveBeenCalledWith(
      'More results exist, raise --limit',
    );
    expect(console.log).not.toHaveBeenCalled();
  });
});
