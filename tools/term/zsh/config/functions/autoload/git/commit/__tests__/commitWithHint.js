import { __, commitWithHint } from '../__lib/commitWithHint.js';

describe('commitWithHint', () => {
  describe('getDiff', () => {
    it('delegates to getDiff with only yarn.lock excluded', async () => {
      vi.spyOn(__, 'getDiff').mockReturnValue('diff text');
      const actual = await commitWithHint.getDiff();
      expect(actual).toEqual('diff text');
      expect(__.getDiff).toHaveBeenCalledWith(['yarn.lock']);
    });
  });
});
