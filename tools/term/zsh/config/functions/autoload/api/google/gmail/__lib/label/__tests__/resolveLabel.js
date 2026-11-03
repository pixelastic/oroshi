import { __, resolveLabel } from '../resolveLabel.js';

describe('resolveLabel', () => {
  beforeEach(() => {
    vi.spyOn(__, 'getLabels').mockReturnValue([
      { labelId: 'INBOX', name: 'INBOX', type: 'system' },
      { labelId: 'Label_1', name: 'Work', type: 'user' },
    ]);
  });

  it.each([
    { title: 'the exact name', name: 'Work' },
    { title: 'the name with another case', name: 'wORK' },
  ])('returns the id of a user label from $title', async ({ name }) => {
    const actual = await resolveLabel(name);

    expect(actual).toEqual('Label_1');
  });

  it.each([
    { title: 'the label does not exist', name: 'Home' },
    { title: 'the name is the one of a system label', name: 'INBOX' },
    { title: 'the name is empty', name: undefined },
  ])('fails with GMAIL_LABEL_NOT_FOUND when $title', async ({ name }) => {
    let actual = null;
    try {
      await resolveLabel(name);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_LABEL_NOT_FOUND');
    expect(actual).toHaveProperty(
      'message',
      `Label ${name} not found. Create it with gmail-label-create`,
    );
  });
});
