import { __, iconGenerate } from '../iconGenerate.js';

describe('iconGenerate', () => {
  const pageId = '11111111-1111-1111-1111-111111111111';
  const subPageId = '22222222-2222-2222-2222-222222222222';
  const subSubPageId = '33333333-3333-3333-3333-333333333333';
  const tmpDirectory = '/tmp/notion-icon';

  const paragraph = (id, hasChildren = false) => ({
    id,
    type: 'paragraph',
    has_children: hasChildren,
  });
  const image = (url) => ({
    id: `block-${url}`,
    type: 'image',
    has_children: false,
    image: { type: 'file', file: { url } },
  });
  const externalImage = (url) => ({
    id: `block-${url}`,
    type: 'image',
    has_children: false,
    image: { type: 'external', external: { url } },
  });

  // Serve the children of a block from a map of blocks keyed by parent id
  const mockBlocks = (blocksByParent) => {
    vi.spyOn(__, 'callApi').mockImplementation((path) => {
      const parentId = path.replace(/^blocks\//, '').replace(/\/children$/, '');
      return {
        results: blocksByParent[parentId] || [],
        has_more: false,
        next_cursor: null,
      };
    });
  };

  beforeEach(() => {
    vi.spyOn(__, 'parseId').mockImplementation((value) => value);
    vi.spyOn(__, 'iconRead').mockReturnValue('');
    vi.spyOn(__, 'iconUpdate').mockImplementation(({ icon }) => icon);
    vi.spyOn(__, 'pageListRaw').mockReturnValue('');
    vi.spyOn(__, 'tmpDirectory').mockReturnValue(tmpDirectory);
    vi.spyOn(__, 'download').mockReturnValue();
    vi.spyOn(__, 'run').mockReturnValue({ stdout: '' });
    vi.spyOn(__, 'hashFile').mockReturnValue('abc123');
    vi.spyOn(__, 'move').mockReturnValue();
    vi.spyOn(__, 'remove').mockReturnValue();
  });

  it('sets the icon from the first image block of the page', async () => {
    mockBlocks({
      [pageId]: [
        paragraph('p1'),
        image('https://notion.test/first.png'),
        externalImage('https://notion.test/second.png'),
      ],
    });

    const actual = await iconGenerate({ pageId });

    const iconUrl = `https://assets.pixelastic.com/notion/${pageId}-abc123.png`;
    expect(__.download).toHaveBeenCalledWith(
      'https://notion.test/first.png',
      `${tmpDirectory}/${pageId}.png`,
    );
    expect(__.iconUpdate).toHaveBeenCalledWith({ pageId, icon: iconUrl });
    expect(actual).toEqual([{ pageId, status: 'updated', icon: iconUrl }]);
  });

  it('finds an image nested inside child blocks, depth first', async () => {
    mockBlocks({
      [pageId]: [
        paragraph('toggle', true),
        image('https://notion.test/late.png'),
      ],
      toggle: [paragraph('inner', true)],
      inner: [image('https://notion.test/nested.png')],
    });

    await iconGenerate({ pageId });

    expect(__.download).toHaveBeenCalledWith(
      'https://notion.test/nested.png',
      expect.anything(),
    );
  });

  it.each([{ type: 'child_page' }, { type: 'child_database' }])(
    'does not look for an image inside a $type block',
    async ({ type }) => {
      mockBlocks({
        [pageId]: [
          { id: 'child', type, has_children: true },
          image('https://notion.test/own.png'),
        ],
        child: [image('https://notion.test/child.png')],
      });

      await iconGenerate({ pageId });

      expect(__.download).toHaveBeenCalledWith(
        'https://notion.test/own.png',
        expect.anything(),
      );
    },
  );

  it('follows the cursor of the blocks to find an image', async () => {
    vi.spyOn(__, 'callApi').mockImplementation((_path, { query }) => {
      if (query.start_cursor === 'next') {
        return {
          results: [image('https://notion.test/page-two.png')],
          has_more: false,
          next_cursor: null,
        };
      }
      return {
        results: [paragraph('p1')],
        has_more: true,
        next_cursor: 'next',
      };
    });

    await iconGenerate({ pageId });

    expect(__.download).toHaveBeenCalledWith(
      'https://notion.test/page-two.png',
      expect.anything(),
    );
  });

  it('skips a page that already has an icon', async () => {
    mockBlocks({ [pageId]: [image('https://notion.test/a.png')] });
    __.iconRead.mockReturnValue('🎲');

    const actual = await iconGenerate({ pageId });

    expect(__.download).not.toHaveBeenCalled();
    expect(__.iconUpdate).not.toHaveBeenCalled();
    expect(actual).toEqual([{ pageId, status: 'has-icon' }]);
  });

  it('replaces an existing icon with --force', async () => {
    mockBlocks({ [pageId]: [image('https://notion.test/a.png')] });
    __.iconRead.mockReturnValue('🎲');

    await iconGenerate({ pageId, force: true });

    expect(__.iconUpdate).toHaveBeenCalledWith({
      pageId,
      icon: `https://assets.pixelastic.com/notion/${pageId}-abc123.png`,
    });
  });

  it('skips a page with no image without throwing', async () => {
    mockBlocks({ [pageId]: [paragraph('p1')] });

    const actual = await iconGenerate({ pageId });

    expect(__.download).not.toHaveBeenCalled();
    expect(__.iconUpdate).not.toHaveBeenCalled();
    expect(actual).toEqual([{ pageId, status: 'no-image' }]);
  });

  describe('sub-pages', () => {
    beforeEach(() => {
      mockBlocks({
        [pageId]: [image('https://notion.test/a.png')],
        [subPageId]: [image('https://notion.test/b.png')],
        [subSubPageId]: [image('https://notion.test/c.png')],
      });
      vi.spyOn(__, 'pageListRaw').mockImplementation(({ pageId: id }) => {
        const lines = {
          [pageId]: `${subPageId}▮Sub`,
          [subPageId]: `${subSubPageId}▮Sub sub`,
        };
        return lines[id] || '';
      });
    });

    it('are processed with --recursive, at every level', async () => {
      const actual = await iconGenerate({ pageId, recursive: true });

      expect(actual.map((result) => result.pageId)).toEqual([
        pageId,
        subPageId,
        subSubPageId,
      ]);
      expect(__.iconUpdate).toHaveBeenCalledTimes(3);
    });

    it('are not processed without --recursive', async () => {
      const actual = await iconGenerate({ pageId });

      expect(__.pageListRaw).not.toHaveBeenCalled();
      expect(actual.map((result) => result.pageId)).toEqual([pageId]);
    });

    it('are processed even when the parent already has an icon', async () => {
      __.iconRead.mockImplementation(({ pageId: id }) =>
        id === pageId ? '🎲' : '',
      );

      const actual = await iconGenerate({ pageId, recursive: true });

      expect(actual.map((result) => result.status)).toEqual([
        'has-icon',
        'updated',
        'updated',
      ]);
    });
  });

  it('resizes, hashes, then uploads, before setting the icon', async () => {
    mockBlocks({ [pageId]: [image('https://notion.test/a.png')] });
    const steps = [];
    __.download.mockImplementation(() => steps.push('download'));
    __.run.mockImplementation((command) => {
      steps.push(command.includes('rsync') ? 'upload' : 'resize');
      return { stdout: '' };
    });
    __.hashFile.mockImplementation(() => {
      steps.push('hash');
      return 'abc123';
    });
    __.iconUpdate.mockImplementation(() => steps.push('iconUpdate'));

    await iconGenerate({ pageId });

    expect(steps).toEqual([
      'download',
      'resize',
      'hash',
      'upload',
      'iconUpdate',
    ]);
  });

  it('uploads the resized image named after its hash', async () => {
    mockBlocks({ [pageId]: [image('https://notion.test/a.png')] });

    await iconGenerate({ pageId });

    const hashed = `${tmpDirectory}/${pageId}-abc123.png`;
    expect(__.move).toHaveBeenCalledWith(
      `${tmpDirectory}/${pageId}.png`,
      hashed,
    );
    expect(__.run).toHaveBeenCalledWith(
      [
        'zsh',
        '-ic',
        'img-resize "$@"',
        'zsh',
        `${tmpDirectory}/${pageId}.png`,
        '250',
      ],
      expect.anything(),
    );
    expect(__.run).toHaveBeenCalledWith(
      [
        'rsync',
        '-az',
        hashed,
        'pixelastic:./local/www/assets.pixelastic.com/notion',
      ],
      expect.anything(),
    );
    expect(__.remove).toHaveBeenCalledWith(tmpDirectory);
  });

  it('accepts a URL as the page id', async () => {
    const url = `https://www.notion.so/workspace/Meetup-${pageId.replaceAll('-', '')}`;
    __.parseId.mockReturnValue(pageId);
    mockBlocks({ [pageId]: [image('https://notion.test/a.png')] });

    const actual = await iconGenerate({ pageId: url });

    expect(__.parseId).toHaveBeenCalledWith(url);
    expect(actual).toHaveProperty('0.pageId', pageId);
  });
});
