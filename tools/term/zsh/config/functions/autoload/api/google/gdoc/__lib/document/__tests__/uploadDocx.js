import { __, uploadDocx } from '../uploadDocx.js';

describe('uploadDocx', () => {
  const getRequest = () => __.callApi.mock.calls[0];
  const getBody = async () => await getRequest()[1].body.text();

  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 'docA', name: 'article' });
  });

  it('sends the upload to the Drive upload endpoint', async () => {
    await uploadDocx({
      path: 'files/docA',
      method: 'PATCH',
      metadata: {},
      content: Buffer.from('docx'),
    });

    const [path, options] = getRequest();
    expect(path).toEqual('files/docA');
    expect(options).toMatchObject({
      baseUrl: 'https://www.googleapis.com/upload/drive/v3',
      method: 'PATCH',
      query: { uploadType: 'multipart', fields: 'id,name' },
    });
  });

  it('sends a multipart request with the metadata part, then the file part', async () => {
    await uploadDocx({
      path: 'files',
      method: 'POST',
      metadata: { name: 'article' },
      content: Buffer.from('docx content'),
    });

    const { headers } = getRequest()[1];
    const boundary = headers['Content-Type'].match(
      /^multipart\/related; boundary=(.+)$/,
    )[1];
    const body = await getBody();
    const [, metadataPart, filePart] = body.split(`--${boundary}`);

    expect(body.trimEnd().endsWith(`--${boundary}--`)).toEqual(true);
    expect(metadataPart).toContain('Content-Type: application/json');
    expect(metadataPart).toContain('"name":"article"');
    expect(filePart).toContain(
      'Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
    expect(filePart).toContain('docx content');
  });

  it('returns the response of the API', async () => {
    const actual = await uploadDocx({
      path: 'files',
      method: 'POST',
      metadata: {},
      content: Buffer.from('docx'),
    });

    expect(actual).toEqual({ id: 'docA', name: 'article' });
  });
});
