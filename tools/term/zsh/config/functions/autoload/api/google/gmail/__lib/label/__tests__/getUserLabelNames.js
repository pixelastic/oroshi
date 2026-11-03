import { __, getUserLabelNames } from '../getUserLabelNames.js';

describe('getUserLabelNames', () => {
  /**
   * Build a Gmail Thread holding Messages with the given labelIds
   * @param {string[][]} labelIds - Label ids of each Message
   * @returns {object} Gmail thread resource
   */
  function thread(labelIds) {
    return {
      id: 't1',
      messages: labelIds.map((ids, index) => ({
        id: `m${index}`,
        labelIds: ids,
      })),
    };
  }

  beforeEach(() => {
    vi.spyOn(__, 'getLabels').mockReturnValue([
      {
        labelId: 'Label_1',
        name: 'Work',
        type: 'user',
        backgroundColor: '#16a766',
      },
      { labelId: 'Label_2', name: 'Misc', type: 'user' },
      { labelId: 'INBOX', name: 'INBOX', type: 'system' },
      { labelId: 'UNREAD', name: 'UNREAD', type: 'system' },
      {
        labelId: 'CATEGORY_PROMOTIONS',
        name: 'CATEGORY_PROMOTIONS',
        type: 'system',
      },
    ]);
  });

  it.each([
    {
      title: 'returns the names and colors of the user labels, by name',
      input: [thread([['Label_1', 'Label_2']])],
      expected: [
        [
          { name: 'Misc', backgroundColor: undefined },
          { name: 'Work', backgroundColor: '#16a766' },
        ],
      ],
    },
    {
      title: 'ignores the system labels',
      input: [thread([['INBOX', 'UNREAD', 'CATEGORY_PROMOTIONS', 'Label_1']])],
      expected: [[{ name: 'Work', backgroundColor: '#16a766' }]],
    },
    {
      title: 'returns each label once for a Thread with several Messages',
      input: [thread([['Label_1'], ['Label_1', 'INBOX'], ['Label_1']])],
      expected: [[{ name: 'Work', backgroundColor: '#16a766' }]],
    },
    {
      title: 'returns an empty list for a Thread without user label',
      input: [thread([['INBOX', 'UNREAD']])],
      expected: [[]],
    },
    {
      title: 'ignores the label ids that no label matches',
      input: [thread([['Label_9']])],
      expected: [[]],
    },
    {
      title: 'returns one list per Thread, in the order of the Threads',
      input: [
        thread([['Label_2']]),
        thread([['INBOX']]),
        thread([['Label_1']]),
      ],
      expected: [
        [{ name: 'Misc', backgroundColor: undefined }],
        [],
        [{ name: 'Work', backgroundColor: '#16a766' }],
      ],
    },
    {
      title: 'handles a Thread without Message',
      input: [{ id: 't1' }],
      expected: [[]],
    },
  ])('$title', async ({ input, expected }) => {
    const actual = await getUserLabelNames(input);

    expect(actual).toEqual(expected);
  });

  it('lists the labels once for all the Threads', async () => {
    await getUserLabelNames([
      thread([['Label_1']]),
      thread([['Label_2']]),
      thread([['INBOX']]),
    ]);

    expect(__.getLabels).toHaveBeenCalledTimes(1);
  });
});
