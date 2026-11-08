import { __, askAccount } from '../askAccount.js';

describe('askAccount', () => {
  let isTTY;
  beforeEach(() => {
    isTTY = process.stdin.isTTY;
    vi.spyOn(__, 'select').mockReturnValue('test');
  });
  afterEach(() => {
    process.stdin.isTTY = isTTY;
  });

  it('suggests default and test, and returns the choice', async () => {
    process.stdin.isTTY = true;

    const actual = await askAccount();

    expect(actual).toEqual('test');
    expect(__.select).toHaveBeenCalledWith(expect.any(String), [
      { name: '🟢 default', value: 'default' },
      { name: '🟡 test', value: 'test' },
    ]);
  });

  it('fails without a terminal', async () => {
    process.stdin.isTTY = false;

    let actual = null;
    try {
      await askAccount();
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'BLUESKY_LOGIN_NOT_INTERACTIVE');
    expect(__.select).not.toHaveBeenCalled();
  });
});
