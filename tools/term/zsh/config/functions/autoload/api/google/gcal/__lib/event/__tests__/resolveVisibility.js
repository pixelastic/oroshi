import { resolveVisibility } from '../resolveVisibility.js';

describe('resolveVisibility', () => {
  it.each([
    {
      title: 'private with isPrivate',
      input: { isPrivate: true },
      expected: 'private',
    },
    {
      title: 'default with isPublic',
      input: { isPublic: true },
      expected: 'default',
    },
    { title: 'undefined with no flag', input: {}, expected: undefined },
  ])('returns $title', ({ input, expected }) => {
    const actual = resolveVisibility(input);

    expect(actual).toEqual(expected);
  });

  it('throws GCAL_VISIBILITY_CONFLICT when both flags are set', () => {
    let actual = null;
    try {
      resolveVisibility({ isPrivate: true, isPublic: true });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GCAL_VISIBILITY_CONFLICT');
  });
});
