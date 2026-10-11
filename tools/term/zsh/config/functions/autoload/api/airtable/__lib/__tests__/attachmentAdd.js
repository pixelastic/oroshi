import path from 'node:path';
import { _ } from 'golgoth';
import { remove, tmpDirectory, write } from 'firost';
import { __, airtableAttachmentAdd } from '../attachmentAdd.js';

describe('airtableAttachmentAdd', () => {
  let testDirectory = null;
  let filepath = null;

  beforeEach(async () => {
    testDirectory = tmpDirectory('airtable-attachment');
    filepath = path.join(testDirectory, 'logo.png');
    await write('Hello world', filepath);
    vi.spyOn(__, 'callApi').mockReturnValue({
      id: 'recABC',
      fields: {
        fldLOGO: [
          { id: 'attOLD', filename: 'old.png' },
          { id: 'attNEW', filename: 'logo.png' },
        ],
      },
    });
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  const addOptions = (options) => ({
    base: 'appDEVREL123',
    record: 'recABC',
    field: 'Logo',
    file: filepath,
    contentType: 'image/png',
    ...options,
  });
  const sentBody = () => __.callApi.mock.calls[0][1].body;

  describe('upload', () => {
    it('sends one upload request with the content type, file name and base64 content', async () => {
      await airtableAttachmentAdd(addOptions());

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

    it('returns the ID of the new Attachment, not of the existing ones', async () => {
      const actual = await airtableAttachmentAdd(addOptions());
      expect(actual).toEqual('attNEW');
    });

    it('sends nothing about the existing Attachments', async () => {
      await airtableAttachmentAdd(addOptions());
      const actual = _.chain(sentBody()).keys().sortBy().value();
      expect(actual).toEqual(['contentType', 'file', 'filename']);
    });

    it('accepts a file of exactly 5 MB', async () => {
      await write('a'.repeat(5 * 1024 * 1024), filepath);

      const actual = await airtableAttachmentAdd(addOptions());
      expect(actual).toEqual('attNEW');
    });
  });

  describe('local errors', () => {
    it.each([
      {
        title: 'the file is missing',
        content: null,
        expected: (file) => `File not found: ${file}`,
      },
      {
        title: 'the file is over 5 MB',
        content: 'a'.repeat(5 * 1024 * 1024 + 1),
        expected: (file) => `File is larger than 5 MB: ${file}`,
      },
    ])(
      'throws without a request when $title',
      async ({ content, expected }) => {
        const file = path.join(testDirectory, 'other.png');
        if (content) {
          await write(content, file);
        }

        let actual = null;
        try {
          await airtableAttachmentAdd(addOptions({ file }));
        } catch (error) {
          actual = error;
        }
        expect(actual).toHaveProperty('message', expected(file));
        expect(__.callApi).not.toHaveBeenCalled();
      },
    );
  });
});
