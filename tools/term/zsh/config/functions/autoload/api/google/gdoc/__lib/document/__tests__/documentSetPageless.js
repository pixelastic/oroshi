import { __, documentSetPageless } from '../documentSetPageless.js';

describe('documentSetPageless', () => {
  beforeEach(() => {
    vi.spyOn(__, 'callApi').mockReturnValue({});
  });

  it('switches the Document to pageless with a batchUpdate', async () => {
    await documentSetPageless('docA');

    expect(__.callApi).toHaveBeenCalledWith('documents/docA:batchUpdate', {
      method: 'POST',
      body: {
        requests: [
          {
            updateDocumentStyle: {
              documentStyle: { documentFormat: { documentMode: 'PAGELESS' } },
              fields: 'documentFormat',
            },
          },
        ],
      },
    });
  });
});
