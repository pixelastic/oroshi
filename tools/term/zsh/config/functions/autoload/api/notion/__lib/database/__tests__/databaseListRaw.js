import { _ } from 'golgoth';
import { firostError } from 'firost';
import { __, databaseListRaw } from '../databaseListRaw.js';

describe('databaseListRaw', () => {
  const databaseId = '3937be57-b8fa-8032-8fb5-f25db51eaf21';
  const dataSourceId = '3937be57-b8fa-8071-8d59-000bce1aca9c';
  const database = {
    id: databaseId,
    data_sources: [{ id: dataSourceId, name: 'Meetups' }],
  };

  const row = (id, title = id) => ({
    object: 'page',
    id,
    properties: {
      Tags: { id: 'tags', type: 'multi_select', multi_select: [] },
      Name: { id: 'title', type: 'title', title: [{ plain_text: title }] },
    },
  });

  // Pages of rows, chained by cursor, so that a page is served by the cursor
  // the module sends. Like the API, a page holds at most page_size rows
  const mockPages = (pages) => {
    vi.spyOn(__, 'callApi').mockImplementation((path, options) => {
      if (path.startsWith('databases/')) {
        return database;
      }
      const cursor = options.body.start_cursor;
      const index = cursor ? Number(cursor.replace('cursor', '')) : 0;
      const hasMore = index + 1 < pages.length;
      return {
        results: _.take(pages[index], options.body.page_size),
        has_more: hasMore,
        next_cursor: hasMore ? `cursor${index + 1}` : null,
      };
    });
  };

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockReturnValue(databaseId);
    vi.spyOn(__, 'resolveDataSource').mockReturnValue({ id: dataSourceId });
    mockPages([[row('rowA', 'Paris Meetup'), row('rowB', 'Lyon')]]);
  });

  it.each([
    {
      title: 'prints one line per row, id first',
      pages: [[row('rowA', 'Paris Meetup'), row('rowB', 'Lyon')]],
      expected: 'rowA▮Paris Meetup\nrowB▮Lyon',
    },
    {
      title: 'joins the parts of a rich text title',
      pages: [
        [
          {
            id: 'rowA',
            properties: {
              Name: {
                type: 'title',
                title: [{ plain_text: 'Paris ' }, { plain_text: 'Meetup' }],
              },
            },
          },
        ],
      ],
      expected: 'rowA▮Paris Meetup',
    },
    {
      title: 'escapes separators and newlines of the titles',
      pages: [[row('rowA', 'Line one\nLine▮two▯three')]],
      expected: 'rowA▮Line one Linetwothree',
    },
    {
      title: 'prints an empty line for an empty database',
      pages: [[]],
      expected: '',
    },
  ])('$title', async ({ pages, expected }) => {
    mockPages(pages);

    const actual = await databaseListRaw({ databaseId });

    expect(actual).toEqual(expected);
  });

  it('queries the data source of the database', async () => {
    await databaseListRaw({ databaseId });

    expect(__.resolveDataSource).toHaveBeenCalledWith(database);
    expect(__.callApi).toHaveBeenCalledWith(
      `data_sources/${dataSourceId}/query`,
      { method: 'POST', body: { page_size: 25 } },
    );
  });

  it('sends the filter and the sort to the query', async () => {
    const filter = { property: 'Tags', multi_select: { contains: 'WORK' } };
    const sorts = [{ property: 'Name', direction: 'ascending' }];

    await databaseListRaw({
      databaseId,
      filter: JSON.stringify(filter),
      sort: JSON.stringify(sorts),
    });

    expect(__.callApi).toHaveBeenCalledWith(
      `data_sources/${dataSourceId}/query`,
      { method: 'POST', body: { page_size: 25, filter, sorts } },
    );
  });

  it('accepts a URL as the database id', async () => {
    const url = `https://www.notion.so/workspace/Meetups-${databaseId.replaceAll('-', '')}?v=abc`;

    await databaseListRaw({ databaseId: url });

    expect(__.parseId).toHaveBeenCalledWith(url);
    expect(__.callApi).toHaveBeenCalledWith(`databases/${databaseId}`);
  });

  it('follows the cursor until the limit of rows is reached', async () => {
    mockPages([[row('a0'), row('a1')], [row('b0'), row('b1')], [row('c0')]]);

    const actual = await databaseListRaw({ databaseId, limit: 3 });

    expect(actual).toEqual('a0▮a0\na1▮a1\nb0▮b0');
    expect(
      _.chain(__.callApi.mock.calls)
        .filter('[1].body')
        .map('[1].body.start_cursor')
        .value(),
    ).toEqual([undefined, 'cursor1']);
  });

  it('stops when the API has no more rows, even below the limit', async () => {
    mockPages([[row('a0')], [row('b0')]]);

    const actual = await databaseListRaw({ databaseId, limit: 50 });

    expect(actual).toEqual('a0▮a0\nb0▮b0');
  });

  it.each(['filter', 'sort'])(
    'throws a clear error when the %s is not valid JSON',
    async (key) => {
      let actual = null;
      try {
        await databaseListRaw({ databaseId, [key]: '{not json' });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'NOTION_JSON_INVALID');
      expect(actual.message).toContain(`--${key}`);
    },
  );

  it('throws when the database id is invalid', async () => {
    __.parseId.mockImplementation(() => {
      throw firostError('NOTION_ID_INVALID', 'No Notion id found');
    });

    let actual = null;
    try {
      await databaseListRaw({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'NOTION_ID_INVALID');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  describe('toLine', () => {
    it('joins the id and the title', () => {
      const actual = __.toLine(row('rowA', 'Paris Meetup'));

      expect(actual).toEqual('rowA▮Paris Meetup');
    });
  });
});
