import { formatBase } from '../formatBase.js';

describe('formatBase', () => {
  it('returns the Base as the API gave it', () => {
    const input = { id: 'appA', name: 'DevRel', permissionLevel: 'create' };

    const actual = formatBase(input);

    expect(actual).toEqual({
      id: 'appA',
      name: 'DevRel',
      permissionLevel: 'create',
    });
  });
});
