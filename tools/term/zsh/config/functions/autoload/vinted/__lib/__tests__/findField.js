import { findField } from '../findField.js';

describe('findField', () => {
  it('throws an error naming the missing field', async () => {
    const waitFor = vi.fn().mockImplementation(() => {
      throw new Error('timeout');
    });
    const locator = { first: () => ({ waitFor }) };
    const page = { getByTestId: () => locator };

    let actual = null;
    try {
      await findField(page, 'title--input');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'VINTED_FORM_FIELD_MISSING');
    expect(actual).toHaveProperty(
      'message',
      'Form field "title--input" not found, the Vinted form may have changed',
    );
  });
});
