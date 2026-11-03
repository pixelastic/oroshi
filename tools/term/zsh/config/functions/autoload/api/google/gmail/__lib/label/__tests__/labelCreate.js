import { __, labelCreate } from '../labelCreate.js';

describe('labelCreate', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getLabels').mockReturnValue([
      { labelId: 'INBOX', name: 'INBOX', type: 'system' },
      { labelId: 'Label_1', name: 'Work', type: 'user' },
    ]);
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'Label_2',
      name: 'Home',
      type: 'user',
    });
  });

  it('creates the label and prints its id and name', async () => {
    const actual = await labelCreate({ name: 'Home' });

    expect(__.callApi).toHaveBeenCalledWith('labels', {
      method: 'POST',
      body: { name: 'Home' },
    });
    expect(actual).toEqual({ labelId: 'Label_2', name: 'Home' });
  });

  it.each([
    {
      title: 'the name is missing',
      options: {},
      expected: 'GMAIL_LABEL_NAME_MISSING',
    },
    {
      title: 'the label exists',
      options: { name: 'Work' },
      expected: 'GMAIL_LABEL_EXISTS',
    },
    {
      title: 'the label exists with another case',
      options: { name: 'wORK' },
      expected: 'GMAIL_LABEL_EXISTS',
    },
    {
      title: 'the name is a system label name',
      options: { name: 'INBOX' },
      expected: 'GMAIL_LABEL_NAME_SYSTEM',
    },
    {
      title: 'the name is a system label name with another case',
      options: { name: 'inbox' },
      expected: 'GMAIL_LABEL_NAME_SYSTEM',
    },
  ])(
    'fails with $expected when $title, with no creation',
    async ({ options, expected }) => {
      let actual = null;
      try {
        await labelCreate(options);
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', expected);
      expect(__.callApi).not.toHaveBeenCalled();
    },
  );
});
