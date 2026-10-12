import { firostError } from 'firost';
import { __, attachmentReplace } from '../attachmentReplace.js';

describe('attachmentReplace', () => {
  const updated = { id: 'recABC', fields: { Logo: [{ id: 'attNEW' }] } };

  beforeEach(() => {
    vi.spyOn(__, 'attachmentAdd').mockReturnValue({
      id: 'recABC',
      fields: {
        Logo: [
          { id: 'attOLD1', filename: 'old1.png' },
          { id: 'attOLD2', filename: 'old2.png' },
          { id: 'attNEW', filename: 'logo.png' },
        ],
      },
    });
    vi.spyOn(__, 'recordUpdate').mockReturnValue(updated);
  });

  const replaceOptions = (options) => ({
    baseId: 'appDEVREL123',
    tableId: 'Meetups',
    recordId: 'recABC',
    field: 'Logo',
    file: './logo.png',
    ...options,
  });

  it('uploads the file with the options it was given', async () => {
    await attachmentReplace(replaceOptions());

    expect(__.attachmentAdd).toHaveBeenCalledWith(replaceOptions());
  });

  it('keeps only the new Attachment', async () => {
    await attachmentReplace(replaceOptions());

    expect(__.recordUpdate).toHaveBeenCalledWith({
      baseId: 'appDEVREL123',
      tableId: 'Meetups',
      recordId: 'recABC',
      content: { Logo: [{ id: 'attNEW' }] },
    });
  });

  it('returns the updated Record', async () => {
    const actual = await attachmentReplace(replaceOptions());

    expect(actual).toEqual(updated);
  });

  it('only adds the file when the Field was empty', async () => {
    const added = { id: 'recABC', fields: { Logo: [{ id: 'attNEW' }] } };
    __.attachmentAdd.mockReturnValue(added);

    const actual = await attachmentReplace(replaceOptions());

    expect(actual).toEqual(added);
    expect(__.recordUpdate).not.toHaveBeenCalled();
  });

  it('throws and leaves the old Attachments untouched when the upload fails', async () => {
    __.attachmentAdd.mockImplementation(() => {
      throw firostError('AIRTABLE_REQUEST_FAILED', 'Upload failed');
    });

    let actual = null;
    try {
      await attachmentReplace(replaceOptions());
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'AIRTABLE_REQUEST_FAILED');
    expect(__.recordUpdate).not.toHaveBeenCalled();
  });
});
