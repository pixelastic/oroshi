import { main } from '../main.js';

describe('main', () => {
  it('fails when patching is impossible', async () => {
    let actual = null;
    try {
      await main({
        binaryPath: '/nope/claude.exe',
        colorsPath: '/nope/colors.json',
      });
    } catch (error) {
      actual = error;
    }
    expect(actual).toHaveProperty('code', 'ENOENT');
  });
});
