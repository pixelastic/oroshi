import { formatProject } from '../formatProject.js';

describe('formatProject', () => {
  it('returns the project as the API returned it', () => {
    const response = {
      slug: 'gh/pixelastic/firost',
      name: 'firost',
      vcs_info: { default_branch: 'main' },
    };

    const actual = formatProject(response);

    expect(actual).toEqual(response);
  });
});
