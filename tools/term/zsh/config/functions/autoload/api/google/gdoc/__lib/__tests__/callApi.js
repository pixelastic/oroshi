import { __ as googleInternals } from '@oroshi/google/callApi.js';
import { callApi } from '../callApi.js';

describe('callApi', () => {
  const response = (status, text) => ({
    ok: status >= 200 && status < 300,
    status,
    text: () => text,
  });

  beforeEach(() => {
    vi.spyOn(googleInternals, 'getConfig').mockReturnValue({
      tokens: { access_token: 'token', expires_at: Date.now() + 3_600_000 },
    });
    vi.spyOn(googleInternals, 'fetch').mockReturnValue(
      response(200, JSON.stringify({ documentId: 'docA' })),
    );
  });

  it('calls the Docs API by default', async () => {
    const actual = await callApi('documents/docA');

    expect(actual).toEqual({ documentId: 'docA' });
    const [url, request] = googleInternals.fetch.mock.calls[0];
    expect(url).toEqual('https://docs.googleapis.com/v1/documents/docA');
    expect(request).toHaveProperty('headers.Authorization', 'Bearer token');
  });

  it('calls the host of the base URL it is given', async () => {
    await callApi('files/fileA', {
      baseUrl: 'https://www.googleapis.com/drive/v3',
    });

    const actual = googleInternals.fetch.mock.calls[0][0];
    expect(actual).toEqual('https://www.googleapis.com/drive/v3/files/fileA');
  });

  it('throws GDOC_REQUEST_FAILED on a failure', async () => {
    googleInternals.fetch.mockReturnValue(response(404, 'NOT_FOUND'));

    let actual = null;
    try {
      await callApi('documents/docA');
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GDOC_REQUEST_FAILED');
    expect(actual).toHaveProperty('message', '404 NOT_FOUND');
  });
});
