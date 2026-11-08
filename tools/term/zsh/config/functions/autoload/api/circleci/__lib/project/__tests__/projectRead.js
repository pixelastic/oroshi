import { __, projectRead } from '../projectRead.js';

describe('projectRead', () => {
  // A minimal inline response: only the fields the test needs
  const response = { slug: 'gh/pixelastic/firost' };

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue(response);
    vi.spyOn(__, 'formatProject').mockReturnValue({ slug: 'formatted' });
  });

  it('calls the API with the slug of the project', async () => {
    await projectRead({ projectSlug: 'gh/pixelastic/firost' });

    expect(__.callApi).toHaveBeenCalledWith('project/gh/pixelastic/firost');
  });

  it('returns the response of the API, formatted', async () => {
    const actual = await projectRead({ projectSlug: 'gh/pixelastic/firost' });

    expect(__.formatProject).toHaveBeenCalledWith(response);
    expect(actual).toEqual({ slug: 'formatted' });
  });

  it.each([
    { title: 'empty', input: '' },
    { title: 'missing', input: undefined },
  ])('throws when the slug is $title', async ({ input }) => {
    let actual = null;
    try {
      await projectRead({ projectSlug: input });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'CIRCLECI_MISSING_ARGUMENT');
    expect(actual).toHaveProperty(
      'message',
      'Pass the slug of the project (gh/<org>/<repo>)',
    );
    expect(__.callApi).not.toHaveBeenCalled();
  });
});
