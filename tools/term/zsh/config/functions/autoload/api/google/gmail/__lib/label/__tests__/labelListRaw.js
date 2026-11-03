import { __, labelListRaw } from '../labelListRaw.js';

describe('labelListRaw', () => {
  /**
   * Read the names of the rows
   * @param {string} output - Raw lines
   * @returns {string[]} Label names
   */
  function names(output) {
    return output.split('\n').map((line) => line.split('▮')[1]);
  }

  beforeEach(() => {
    vi.spyOn(__, 'getLabels').mockReturnValue([
      { labelId: 'INBOX', name: 'INBOX', type: 'system' },
      {
        labelId: 'Label_1',
        name: 'Work',
        type: 'user',
        backgroundColor: '#16a766',
        textColor: '#ffffff',
      },
      { labelId: 'Label_2', name: 'Home', type: 'user' },
      { labelId: 'Label_3', name: 'Network', type: 'user' },
      { labelId: 'Label_4', name: 'A▮B▯C', type: 'user' },
    ]);
  });

  it('prints one line per user label with five columns', async () => {
    const actual = await labelListRaw({});

    expect(actual.split('\n')).toEqual([
      'Label_1▮Work▮user▮#16a766▮#ffffff',
      'Label_2▮Home▮user▮▮',
      'Label_3▮Network▮user▮▮',
      'Label_4▮ABC▮user▮▮',
    ]);
  });

  it('prints the user labels only', async () => {
    const actual = await labelListRaw({});

    expect(names(actual)).not.toContain('INBOX');
  });

  it.each([
    { title: 'lower case', query: 'work', expected: ['Work', 'Network'] },
    { title: 'upper case', query: 'WORK', expected: ['Work', 'Network'] },
    { title: 'a part of the name', query: 'ome', expected: ['Home'] },
  ])('filters by name, with $title', async ({ query, expected }) => {
    const actual = await labelListRaw({ query });

    expect(names(actual)).toEqual(expected);
  });

  it('prints nothing for a filter without match', async () => {
    const actual = await labelListRaw({ query: 'nope' });

    expect(actual).toEqual('');
  });
});
