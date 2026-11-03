import { __, getLabels } from '../getLabels.js';

describe('getLabels', () => {
  it('asks the API for the labels once', async () => {
    vi.spyOn(__, 'callApi').mockReturnValue({ labels: [] });

    await getLabels();

    expect(__.callApi).toHaveBeenCalledTimes(1);
    expect(__.callApi).toHaveBeenCalledWith('labels');
  });

  it('returns the id, name, type and colors of every label', async () => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      labels: [
        {
          id: 'Label_1',
          name: 'Work',
          type: 'user',
          color: { backgroundColor: '#16a766', textColor: '#ffffff' },
        },
        { id: 'INBOX', name: 'INBOX', type: 'system' },
      ],
    });

    const actual = await getLabels();

    expect(actual).toEqual([
      {
        labelId: 'Label_1',
        name: 'Work',
        type: 'user',
        backgroundColor: '#16a766',
        textColor: '#ffffff',
      },
      {
        labelId: 'INBOX',
        name: 'INBOX',
        type: 'system',
        backgroundColor: undefined,
        textColor: undefined,
      },
    ]);
  });

  it('returns an empty list when the response has no labels', async () => {
    vi.spyOn(__, 'callApi').mockReturnValue({});

    const actual = await getLabels();

    expect(actual).toEqual([]);
  });
});
