import path from 'node:path';
import { _ } from 'golgoth';
import { remove, tmpDirectory, write } from 'firost';
import { __ as apiMock } from '../api.js';
import { airtableAttachmentReplace } from '../attachmentReplace.js';

describe('airtableAttachmentReplace', () => {
  let testDirectory = null;
  let filepath = null;
  let stored = null;

  // A small fake of Airtable: it holds the Attachments of the Field, a GET
  // reads them, an upload appends one, and a PATCH keeps the given IDs
  const fakeAirtable = (url, request) => {
    const respond = (json) => ({ ok: true, status: 200, json: () => json });
    if (request.method === 'GET') {
      return respond({ records: [{ id: 'recABC', fields: { Logo: stored } }] });
    }
    if (request.method === 'POST') {
      stored = [...stored, { id: 'attNEW', filename: 'logo.png' }];
      return respond({ id: 'recABC', fields: { fldLOGO: stored } });
    }
    const keptIds = _.map(JSON.parse(request.body).fields.Logo, 'id');
    stored = _.filter(stored, ({ id }) => _.includes(keptIds, id));
    return respond({ id: 'recABC', fields: { Logo: stored } });
  };

  beforeEach(async () => {
    testDirectory = tmpDirectory('airtable-attachment-replace');
    filepath = path.join(testDirectory, 'logo.png');
    await write('Hello world', filepath);

    stored = [
      { id: 'attOLD1', filename: 'old1.png' },
      { id: 'attOLD2', filename: 'old2.png' },
    ];
    vi.stubEnv('AIRTABLE_TOKEN_WRITE', 'write-token-abc');
    vi.stubEnv('AIRTABLE_TOKEN_READ', 'read-token-abc');
    vi.spyOn(apiMock, 'fetch').mockImplementation(fakeAirtable);
  });
  afterEach(async () => {
    vi.unstubAllEnvs();
    await remove(testDirectory);
  });

  const replaceOptions = (options) => ({
    base: 'appDEVREL123',
    table: 'Meetups',
    record: 'recABC',
    field: 'Logo',
    file: filepath,
    contentType: 'image/png',
    ...options,
  });
  const methods = () =>
    _.map(apiMock.fetch.mock.calls, ([, { method }]) => method);

  it('leaves only the new Attachment in the Field', async () => {
    await airtableAttachmentReplace(replaceOptions());

    expect(_.map(stored, 'id')).toEqual(['attNEW']);
  });

  it('returns the ID of the new Attachment', async () => {
    const actual = await airtableAttachmentReplace(replaceOptions());

    expect(actual).toEqual('attNEW');
  });

  it('uploads the new file before it removes the old ones', async () => {
    await airtableAttachmentReplace(replaceOptions());

    expect(methods()).toEqual(['GET', 'POST', 'GET', 'PATCH']);
  });

  it('only adds the file when the Field is empty', async () => {
    stored = [];

    const actual = await airtableAttachmentReplace(replaceOptions());

    expect(actual).toEqual('attNEW');
    expect(_.map(stored, 'id')).toEqual(['attNEW']);
    expect(methods()).toEqual(['GET', 'POST']);
  });

  describe('failed upload', () => {
    it('throws, and leaves the old Attachments untouched', async () => {
      apiMock.fetch.mockImplementation((url, request) =>
        request.method === 'POST'
          ? {
              ok: false,
              status: 500,
              json: () => ({ error: { message: 'Upload failed' } }),
            }
          : fakeAirtable(url, request),
      );

      let actual = null;
      try {
        await airtableAttachmentReplace(replaceOptions());
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('message', 'Upload failed');
      expect(_.map(stored, 'id')).toEqual(['attOLD1', 'attOLD2']);
      expect(methods()).not.toContain('PATCH');
    });

    it('throws, and leaves the old Attachments untouched, when the file is missing', async () => {
      const missingFile = path.join(testDirectory, 'nope.png');

      let actual = null;
      try {
        await airtableAttachmentReplace(replaceOptions({ file: missingFile }));
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty(
        'message',
        `File not found: ${missingFile}`,
      );
      expect(_.map(stored, 'id')).toEqual(['attOLD1', 'attOLD2']);
    });
  });
});
