import { _ } from 'golgoth';
import { firostError } from 'firost';
import { __, pageListRaw } from '../pageListRaw.js';

describe('pageListRaw', () => {
  const pageId = '3e07be57-b8fa-81bc-b066-c0275ed4b363';

  const childPage = (id, title = id) => ({
    object: 'block',
    id,
    type: 'child_page',
    child_page: { title },
  });
  const paragraph = (id) => ({ object: 'block', id, type: 'paragraph' });

  // Pages of blocks, chained by cursor, so that a page is served by the
  // cursor the module sends. Like the API, a page holds at most page_size blocks
  const mockPages = (pages) => {
    vi.spyOn(__, 'callApi').mockImplementation((path, options) => {
      const cursor = options.query.start_cursor;
      const index = cursor ? Number(cursor.replace('cursor', '')) : 0;
      const hasMore = index + 1 < pages.length;
      return {
        results: _.take(pages[index], options.query.page_size),
        has_more: hasMore,
        next_cursor: hasMore ? `cursor${index + 1}` : null,
      };
    });
  };

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockReturnValue(pageId);
    mockPages([[childPage('subA', 'Paris Meetup'), childPage('subB', 'Lyon')]]);
  });

  it.each([
    {
      title: 'prints one line per sub-page, id first',
      pages: [[childPage('subA', 'Paris Meetup'), childPage('subB', 'Lyon')]],
      expected: 'subA▮Paris Meetup\nsubB▮Lyon',
    },
    {
      title: 'keeps only the sub-pages among the blocks',
      pages: [
        [
          paragraph('blockA'),
          childPage('subA'),
          { object: 'block', id: 'dbA', type: 'child_database' },
          childPage('subB'),
        ],
      ],
      expected: 'subA▮subA\nsubB▮subB',
    },
    {
      title: 'escapes separators and newlines of the titles',
      pages: [[childPage('subA', 'Line one\nLine▮two▯three')]],
      expected: 'subA▮Line one Linetwothree',
    },
    {
      title: 'prints an empty line for a page without sub-pages',
      pages: [[paragraph('blockA')]],
      expected: '',
    },
  ])('$title', async ({ pages, expected }) => {
    mockPages(pages);

    const actual = await pageListRaw({ pageId });

    expect(actual).toEqual(expected);
  });

  it('reads the children of the parent page', async () => {
    await pageListRaw({ pageId });

    expect(__.callApi).toHaveBeenCalledWith(`blocks/${pageId}/children`, {
      query: { page_size: 25 },
    });
  });

  it('accepts a URL as the parent page', async () => {
    const url = `https://www.notion.so/workspace/Meetup-${pageId.replaceAll('-', '')}`;

    await pageListRaw({ pageId: url });

    expect(__.parseId).toHaveBeenCalledWith(url);
    expect(__.callApi).toHaveBeenCalledWith(
      `blocks/${pageId}/children`,
      expect.anything(),
    );
  });

  it('follows the cursor until the limit of sub-pages is reached', async () => {
    mockPages([
      [paragraph('x'), childPage('a0'), childPage('a1')],
      [childPage('b0'), childPage('b1')],
      [childPage('c0')],
    ]);

    const actual = await pageListRaw({ pageId, limit: 3 });

    expect(actual).toEqual('a0▮a0\na1▮a1\nb0▮b0');
    expect(_.map(__.callApi.mock.calls, '[1].query.start_cursor')).toEqual([
      undefined,
      'cursor1',
    ]);
  });

  it('stops when the API has no more blocks, even below the limit', async () => {
    mockPages([[childPage('a0')], [childPage('b0')]]);

    const actual = await pageListRaw({ pageId, limit: 50 });

    expect(actual).toEqual('a0▮a0\nb0▮b0');
    expect(__.callApi).toHaveBeenCalledTimes(2);
  });

  it('throws when the parent page id is invalid', async () => {
    __.parseId.mockImplementation(() => {
      throw firostError('NOTION_ID_INVALID', 'No Notion id found');
    });

    let actual = null;
    try {
      await pageListRaw({});
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'NOTION_ID_INVALID');
    expect(__.callApi).not.toHaveBeenCalled();
  });

  describe('toLine', () => {
    it('joins the id and the title', () => {
      const actual = __.toLine(childPage('subA', 'Paris Meetup'));

      expect(actual).toEqual('subA▮Paris Meetup');
    });
  });
});
