import { __, pageCreate } from '../pageCreate.js';

describe('pageCreate', () => {
  const parentPageId = '11111111-1111-1111-1111-111111111111';
  const parentDatabaseId = '22222222-2222-2222-2222-222222222222';
  const dataSourceId = '33333333-3333-3333-3333-333333333333';
  const newPageId = '44444444-4444-4444-4444-444444444444';
  const properties = { title: { title: [{ text: { content: 'Paris' } }] } };
  const formatted = {
    id: newPageId,
    url: 'u',
    properties: {},
    markdown: '# A',
  };

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockImplementation((input) => input);
    vi.spyOn(__, 'getJsonFromOptions').mockReturnValue(properties);
    vi.spyOn(__, 'read').mockReturnValue('# From file');
    vi.spyOn(__, 'callApi').mockImplementation((path) =>
      path.startsWith('databases/')
        ? { id: parentDatabaseId, data_sources: [{ id: dataSourceId }] }
        : { id: newPageId },
    );
    vi.spyOn(__, 'pageRead').mockReturnValue(formatted);
  });

  /**
   * Get the body of the POST call to pages
   * @returns {object} The body
   */
  function sentBody() {
    const call = __.callApi.mock.calls.find(([path]) => path === 'pages');
    return call[1].body;
  }

  it('creates a sub-page under a parent Page', async () => {
    await pageCreate({ parentPageId, data: '{}' });

    expect(__.callApi).toHaveBeenCalledWith('pages', {
      method: 'POST',
      body: { parent: { type: 'page_id', page_id: parentPageId }, properties },
    });
  });

  it('creates a row under the data source of a parent Database', async () => {
    await pageCreate({ parentDatabaseId, data: '{}' });

    expect(__.callApi).toHaveBeenCalledWith(`databases/${parentDatabaseId}`);
    expect(sentBody().parent).toEqual({
      type: 'data_source_id',
      data_source_id: dataSourceId,
    });
  });

  it.each([
    { title: 'no parent', input: {} },
    { title: 'two parents', input: { parentPageId, parentDatabaseId } },
  ])('throws NOTION_PARENT_MISSING with $title', async ({ input }) => {
    let actual = null;
    try {
      await pageCreate(input);
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'NOTION_PARENT_MISSING');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  it('reads the properties from the data and the data file', async () => {
    await pageCreate({ parentPageId, data: '{"a":1}', dataFile: './a.json' });

    expect(__.getJsonFromOptions).toHaveBeenCalledWith(
      { parentPageId, data: '{"a":1}', dataFile: './a.json' },
      'data',
      {},
    );
  });

  it('writes the content as the markdown of the new Page', async () => {
    await pageCreate({ parentPageId, content: '# Hello' });

    expect(sentBody()).toHaveProperty('markdown', '# Hello');
  });

  it('reads the content from the content file, which wins over the content', async () => {
    await pageCreate({
      parentPageId,
      content: '# Hello',
      contentFile: './body.md',
    });

    expect(__.read).toHaveBeenCalledWith('./body.md');
    expect(sentBody()).toHaveProperty('markdown', '# From file');
  });

  it('accepts URLs as parent ids', async () => {
    __.parseId.mockImplementation((input) => input.replace('https://x/', ''));

    await pageCreate({ parentPageId: `https://x/${parentPageId}` });
    expect(sentBody().parent.page_id).toEqual(parentPageId);

    __.callApi.mockClear();
    await pageCreate({ parentDatabaseId: `https://x/${parentDatabaseId}` });
    expect(__.callApi).toHaveBeenCalledWith(`databases/${parentDatabaseId}`);
  });

  it('returns the new Page, as read', async () => {
    const actual = await pageCreate({ parentPageId });

    expect(__.pageRead).toHaveBeenCalledWith({ pageId: newPageId });
    expect(actual).toEqual(formatted);
  });
});
