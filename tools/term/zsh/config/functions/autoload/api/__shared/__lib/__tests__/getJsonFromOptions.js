import { resolve } from 'node:path';
import { __, getJsonFromOptions } from '../getJsonFromOptions.js';

describe('getJsonFromOptions', () => {
  beforeEach(() => {
    vi.spyOn(__, 'readJson').mockReturnValue({ from: 'file' });
  });

  it('reads the file named by the File key', async () => {
    const actual = await getJsonFromOptions(
      { blueprintFile: './blueprint.json' },
      'blueprint',
    );

    expect(__.readJson).toHaveBeenCalledWith(resolve('./blueprint.json'));
    expect(actual).toEqual({ from: 'file' });
  });

  it('parses the JSON string of the key', async () => {
    const actual = await getJsonFromOptions(
      { blueprint: '{"flow":[]}' },
      'blueprint',
    );

    expect(actual).toEqual({ flow: [] });
  });

  it('lets the file win over the JSON string', async () => {
    const actual = await getJsonFromOptions(
      { blueprint: '{"from":"inline"}', blueprintFile: './blueprint.json' },
      'blueprint',
    );

    expect(actual).toEqual({ from: 'file' });
  });

  it('returns an object value as it is', async () => {
    const actual = await getJsonFromOptions(
      { blueprint: { flow: [] } },
      'blueprint',
    );

    expect(actual).toEqual({ flow: [] });
  });

  it.each([
    {
      title: 'the fallback',
      fallback: { type: 'on-demand' },
      expected: { type: 'on-demand' },
    },
    {
      title: 'undefined without fallback',
      fallback: undefined,
      expected: undefined,
    },
  ])('returns $title when there is neither', async ({ fallback, expected }) => {
    const actual = await getJsonFromOptions({}, 'scheduling', fallback);

    expect(actual).toEqual(expected);
  });
});
