import path from 'node:path';
import { _ } from 'golgoth';
import { firostError, remove, tmpDirectory, write } from 'firost';
import { __, attachmentAdd } from '../attachmentAdd.js';

describe('attachmentAdd', () => {
  let testDirectory = null;
  let filepath = null;
  const record = {
    id: 'recABC',
    fields: {
      Logo: [
        { id: 'attOLD', filename: 'old.png' },
        { id: 'attNEW', filename: 'logo.png' },
      ],
    },
  };

  beforeEach(async () => {
    testDirectory = tmpDirectory('airtable-attachment-add');
    filepath = path.join(testDirectory, 'logo.png');
    await write('Hello world', filepath);
    vi.spyOn(__, 'callApi').mockReturnValue({ id: 'recABC' });
    vi.spyOn(__, 'recordRead').mockReturnValue(record);
    vi.spyOn(__, 'getContentType').mockReturnValue('image/png');
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  const addOptions = (options) => ({
    baseId: 'appDEVREL123',
    tableId: 'Meetups',
    recordId: 'recABC',
    field: 'Logo',
    file: filepath,
    ...options,
  });

  it('sends one upload request with the content type, file name and base64 content', async () => {
    await attachmentAdd(addOptions());

    expect(__.callApi).toHaveBeenCalledTimes(1);
    expect(__.callApi).toHaveBeenCalledWith(
      'https://content.airtable.com/v0/appDEVREL123/recABC/Logo/uploadAttachment',
      {
        method: 'POST',
        body: {
          contentType: 'image/png',
          filename: 'logo.png',
          file: Buffer.from('Hello world').toString('base64'),
        },
      },
    );
  });

  it('sends nothing about the existing Attachments, so Airtable keeps them', async () => {
    await attachmentAdd(addOptions());

    const actual = _.chain(__.callApi.mock.calls[0][1].body)
      .keys()
      .sortBy()
      .value();
    expect(actual).toEqual(['contentType', 'file', 'filename']);
  });

  it('returns the Record, read after the upload', async () => {
    const actual = await attachmentAdd(addOptions());

    expect(__.recordRead).toHaveBeenCalledWith({
      baseId: 'appDEVREL123',
      tableId: 'Meetups',
      recordId: 'recABC',
    });
    expect(actual).toEqual(record);
  });

  it('accepts a file of exactly 5 MB', async () => {
    await write('a'.repeat(5 * 1024 * 1024), filepath);

    const actual = await attachmentAdd(addOptions());

    expect(actual).toEqual(record);
  });

  it.each([
    { title: 'Base', key: 'baseId', code: 'AIRTABLE_BASE_ID_MISSING' },
    { title: 'Table', key: 'tableId', code: 'AIRTABLE_TABLE_ID_MISSING' },
    { title: 'Record', key: 'recordId', code: 'AIRTABLE_RECORD_ID_MISSING' },
    { title: 'Field', key: 'field', code: 'AIRTABLE_FIELD_MISSING' },
    { title: 'File', key: 'file', code: 'AIRTABLE_FILE_MISSING' },
  ])(
    'throws without a request when the $title is missing',
    async ({ key, code }) => {
      let actual = null;
      try {
        await attachmentAdd(addOptions({ [key]: undefined }));
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', code);
      expect(__.callApi).not.toHaveBeenCalled();
    },
  );

  it.each([
    {
      title: 'the file does not exist',
      content: null,
      code: 'AIRTABLE_ATTACHMENT_MISSING_FILE',
      expected: (file) => `File not found: ${file}`,
    },
    {
      title: 'the file is over 5 MB',
      content: 'a'.repeat(5 * 1024 * 1024 + 1),
      code: 'AIRTABLE_ATTACHMENT_TOO_LARGE',
      expected: (file) => `File is larger than 5 MB: ${file}`,
    },
  ])(
    'throws without a request when $title',
    async ({ content, code, expected }) => {
      const file = path.join(testDirectory, 'other.png');
      if (content) {
        await write(content, file);
      }

      let actual = null;
      try {
        await attachmentAdd(addOptions({ file }));
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', code);
      expect(actual).toHaveProperty('message', expected(file));
      expect(__.callApi).not.toHaveBeenCalled();
    },
  );

  it('surfaces the failure of the API for an unknown Record or Field', async () => {
    __.callApi.mockImplementation(() => {
      throw firostError('AIRTABLE_REQUEST_FAILED', 'NOT_FOUND');
    });

    let actual = null;
    try {
      await attachmentAdd(addOptions({ recordId: 'recMISSING' }));
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_REQUEST_FAILED');
    expect(__.recordRead).not.toHaveBeenCalled();
  });
});

describe('attachmentAdd.getContentType', () => {
  let testDirectory = null;

  beforeEach(() => {
    testDirectory = tmpDirectory('airtable-attachment-content-type');
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('detects the content type from the file itself', async () => {
    const filepath = path.join(testDirectory, 'note.txt');
    await write('Hello world', filepath);

    const actual = await __.getContentType(filepath);

    expect(actual).toEqual('text/plain');
  });
});
