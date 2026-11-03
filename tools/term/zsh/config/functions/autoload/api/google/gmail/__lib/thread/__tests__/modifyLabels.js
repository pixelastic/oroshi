import { __, modifyLabels } from '../modifyLabels.js';

describe('modifyLabels', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callThread').mockReturnValue({ id: 't1', messages: [] });
  });

  it.each([
    {
      title: 'adds labels',
      input: { add: ['Label_1'] },
      expected: { addLabelIds: ['Label_1'] },
    },
    {
      title: 'removes labels',
      input: { remove: ['Label_1'] },
      expected: { removeLabelIds: ['Label_1'] },
    },
    {
      title: 'adds and removes labels',
      input: { add: ['Label_1'], remove: ['UNREAD'] },
      expected: { addLabelIds: ['Label_1'], removeLabelIds: ['UNREAD'] },
    },
  ])('$title', async ({ input, expected }) => {
    await modifyLabels({ threadId: 't1', ...input });

    expect(__.callThread).toHaveBeenCalledWith({
      threadId: 't1',
      action: 'modify',
      body: expected,
    });
  });

  it('returns the Thread as the API answers it', async () => {
    const actual = await modifyLabels({ threadId: 't1', add: ['Label_1'] });

    expect(actual).toEqual({ id: 't1', messages: [] });
  });
});
