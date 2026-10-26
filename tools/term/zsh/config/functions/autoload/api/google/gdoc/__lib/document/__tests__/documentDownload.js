import { exists, read, remove, tmpDirectory } from 'firost';
import { __, documentDownload } from '../documentDownload.js';

describe('documentDownload', () => {
  let testDirectory;
  const imageResponse = (text) => ({
    ok: true,
    status: 200,
    arrayBuffer: () => Buffer.from(text),
  });

  beforeEach(() => {
    testDirectory = tmpDirectory('documentDownload');
    vi.spyOn(process, 'cwd').mockReturnValue(testDirectory);
    vi.spyOn(__, 'documentRead').mockReturnValue({
      id: 'docA',
      title: 'Café & Résumé',
      url: 'https://docs.google.com/document/d/docA/edit',
      markdown:
        '# Hello\n\n![one](https://img.test/1)\n\n![two](https://img.test/2)\n',
      images: ['https://img.test/1', 'https://img.test/2'],
    });
    vi.spyOn(__, 'fetch').mockImplementation((url) =>
      imageResponse(`bytes of ${url}`),
    );
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('returns the path of the folder, named after the title', async () => {
    const actual = await documentDownload({ documentId: 'docA' });

    expect(actual).toEqual(`${testDirectory}/cafe-resume`);
  });

  it('reads the Document from its URL or ID', async () => {
    await documentDownload({ documentId: 'docA' });

    expect(__.documentRead).toHaveBeenCalledWith({ documentId: 'docA' });
  });

  it('passes a tab URL through to documentRead', async () => {
    const documentId =
      'https://docs.google.com/document/d/docA/edit?tab=t.tabA';

    await documentDownload({ documentId });

    expect(__.documentRead).toHaveBeenCalledWith({ documentId });
  });

  it('writes the Markdown with links to the local images', async () => {
    await documentDownload({ documentId: 'docA' });

    const actual = await read(`${testDirectory}/cafe-resume/index.md`);
    const expected = '# Hello\n\n![one](image-1.png)\n\n![two](image-2.png)';
    expect(actual).toEqual(expected);
  });

  it.each([
    { input: 'image-1.png', expected: 'bytes of https://img.test/1' },
    { input: 'image-2.png', expected: 'bytes of https://img.test/2' },
  ])('downloads $input', async ({ input, expected }) => {
    await documentDownload({ documentId: 'docA' });

    const actual = await read(`${testDirectory}/cafe-resume/${input}`);
    expect(actual).toEqual(expected);
  });

  it('writes no image for a Document without images', async () => {
    __.documentRead.mockReturnValue({
      title: 'Plain',
      markdown: '# Hello\n',
      images: [],
    });

    await documentDownload({ documentId: 'docA' });

    expect(await exists(`${testDirectory}/plain/index.md`)).toEqual(true);
    expect(await exists(`${testDirectory}/plain/image-1.png`)).toEqual(false);
  });

  it('throws when an image cannot be downloaded', async () => {
    __.fetch.mockReturnValue({ ok: false, status: 403 });

    let actual = null;
    try {
      await documentDownload({ documentId: 'docA' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GDOC_IMAGE_DOWNLOAD_FAILED');
    expect(actual).toHaveProperty('message', '403 https://img.test/1');
  });
});

describe('slugify', () => {
  it.each([
    { input: 'Hello World', expected: 'hello-world' },
    { input: 'Café & Résumé', expected: 'cafe-resume' },
    { input: '  Spaces  Everywhere  ', expected: 'spaces-everywhere' },
    {
      input: 'Monolithic vs. Distributed Agents: How to Choose',
      expected: 'monolithic-vs-distributed-agents-how-to-choose',
    },
  ])('$input -> $expected', ({ input, expected }) => {
    expect(__.slugify(input)).toEqual(expected);
  });
});

describe('replaceImageUrls', () => {
  it.each([
    {
      title: 'replaces URL inside ![alt](url) with local filename',
      input: 'Some text ![photo](https://example.com/img.png) more text',
      mapping: { 'https://example.com/img.png': 'image-1.png' },
      expected: 'Some text ![photo](image-1.png) more text',
    },
    {
      title: 'does not replace the same URL appearing as bare text',
      input:
        'See https://example.com/img.png and ![photo](https://example.com/img.png)',
      mapping: { 'https://example.com/img.png': 'image-1.png' },
      expected: 'See https://example.com/img.png and ![photo](image-1.png)',
    },
    {
      title: 'handles multiple images',
      input: '![a](https://a.com/1.png) text ![b](https://b.com/2.png)',
      mapping: {
        'https://a.com/1.png': 'image-1.png',
        'https://b.com/2.png': 'image-2.png',
      },
      expected: '![a](image-1.png) text ![b](image-2.png)',
    },
  ])('$title', ({ input, mapping, expected }) => {
    const actual = __.replaceImageUrls(input, mapping);
    expect(actual).toEqual(expected);
  });
});
