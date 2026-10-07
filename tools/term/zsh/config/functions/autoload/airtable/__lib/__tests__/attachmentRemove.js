import { _ } from 'golgoth';
import { __ as apiMock } from '../api.js';
import { airtableAttachmentRemove } from '../attachmentRemove.js';

describe('airtableAttachmentRemove', () => {
  beforeEach(() => {
    vi.stubEnv('AIRTABLE_BASE_DEVREL', 'appDEVREL123');
    vi.stubEnv('AIRTABLE_TOKEN_WRITE', 'write-token-abc');
    vi.stubEnv('AIRTABLE_TOKEN_READ', 'read-token-abc');
    // A GET reads the Field, a PATCH updates it
    vi.spyOn(apiMock, 'fetch').mockImplementation((url, request) => ({
      ok: true,
      status: 200,
      json: () =>
        request.method === 'GET'
          ? {
              records: [
                {
                  id: 'recABC',
                  fields: {
                    Logo: [
                      { id: 'attONE', filename: 'one.png' },
                      { id: 'attTWO', filename: 'two.png' },
                      { id: 'attTHREE', filename: 'three.png' },
                    ],
                  },
                },
              ],
            }
          : { id: 'recABC', fields: {} },
    }));
  });
  afterEach(() => {
    vi.unstubAllEnvs();
  });

  const removeOptions = (options) => ({
    base: 'DevRel',
    table: 'Meetups',
    record: 'recABC',
    field: 'Logo',
    ...options,
  });
  const updates = () =>
    _.chain(apiMock.fetch.mock.calls)
      .map(([url, request]) => ({ url, request }))
      .filter(({ request }) => request.method === 'PATCH')
      .value();
  const sentFields = () => JSON.parse(updates()[0].request.body).fields;

  describe('by ID', () => {
    it.each([
      {
        title: 'keeps the other Attachments when removing one',
        attachments: ['attTWO'],
        expected: [{ id: 'attONE' }, { id: 'attTHREE' }],
      },
      {
        title: 'keeps the rest when removing several',
        attachments: ['attONE', 'attTHREE'],
        expected: [{ id: 'attTWO' }],
      },
    ])('$title', async ({ attachments, expected }) => {
      await airtableAttachmentRemove(removeOptions({ attachments }));

      expect(updates()).toHaveLength(1);
      expect(sentFields()).toEqual({ Logo: expected });
    });

    it('updates the Record of the Table with the Write token', async () => {
      await airtableAttachmentRemove(
        removeOptions({ attachments: ['attONE'] }),
      );

      const { url, request } = updates()[0];
      expect(url).toEqual(
        'https://api.airtable.com/v0/appDEVREL123/Meetups/recABC',
      );
      expect(request).toHaveProperty(
        'headers.Authorization',
        'Bearer write-token-abc',
      );
    });
  });

  describe('all', () => {
    it('empties the Field', async () => {
      await airtableAttachmentRemove(removeOptions({ all: true }));

      expect(sentFields()).toEqual({ Logo: [] });
    });
  });

  describe('unknown Attachment', () => {
    it('throws and changes nothing when an ID is not in the Field', async () => {
      let actual = null;
      try {
        await airtableAttachmentRemove(
          removeOptions({ attachments: ['attONE', 'attNOPE'] }),
        );
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty(
        'message',
        'Attachment not in Field Logo: attNOPE',
      );
      expect(updates()).toHaveLength(0);
    });
  });

  describe('Airtable errors', () => {
    it('throws the message of Airtable when the update fails', async () => {
      apiMock.fetch.mockImplementation((url, request) => ({
        ok: request.method === 'GET',
        status: 403,
        json: () =>
          request.method === 'GET'
            ? {
                records: [
                  { id: 'recABC', fields: { Logo: [{ id: 'attONE' }] } },
                ],
              }
            : { error: { type: 'NOT_AUTHORIZED', message: 'Not authorized' } },
      }));

      let actual = null;
      try {
        await airtableAttachmentRemove(removeOptions({ all: true }));
      } catch (error) {
        actual = error;
      }
      expect(actual).toHaveProperty('message', 'Not authorized');
    });
  });
});
