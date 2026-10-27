import { __, askAccount } from '../askAccount.js';

describe('askAccount', () => {
  let isTTY;
  beforeEach(() => {
    isTTY = process.stdin.isTTY;
    vi.spyOn(__, 'select').mockReturnValue('perso');
  });
  afterEach(() => {
    process.stdin.isTTY = isTTY;
  });

  it('suggests default and perso, and returns the choice', async () => {
    process.stdin.isTTY = true;

    const actual = await askAccount();

    expect(actual).toEqual('perso');
    expect(__.select).toHaveBeenCalledWith(expect.any(String), [
      { name: '🔵 default', value: 'default' },
      { name: '🟢 perso', value: 'perso' },
    ]);
  });

  it('fails without a terminal', async () => {
    process.stdin.isTTY = false;

    let actual = null;
    try {
      await askAccount();
    } catch (err) {
      actual = err;
    }

    expect(actual).toHaveProperty('code', 'GOOGLE_LOGIN_NOT_INTERACTIVE');
    expect(__.select).not.toHaveBeenCalled();
  });
});
