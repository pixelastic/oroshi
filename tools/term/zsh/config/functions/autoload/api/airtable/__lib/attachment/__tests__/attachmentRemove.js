import { firostError } from 'firost';
import { __, attachmentRemove } from '../attachmentRemove.js';

describe('attachmentRemove', () => {
  const updated = { id: 'recABC', fields: { Logo: [{ id: 'attB' }] } };

  beforeEach(() => {
    vi.spyOn(__, 'recordRead').mockReturnValue({
      id: 'recABC',
      fields: {
        Logo: [
          { id: 'attA', filename: 'a.png' },
          { id: 'attB', filename: 'b.png' },
          { id: 'attC', filename: 'c.png' },
        ],
      },
    });
    vi.spyOn(__, 'recordUpdate').mockReturnValue(updated);
  });

  const removeOptions = (options) => ({
    baseId: 'appDEVREL123',
    tableId: 'Meetups',
    recordId: 'recABC',
    field: 'Logo',
    ...options,
  });
  const catchError = async (options) => {
    let actual = null;
    try {
      await attachmentRemove(options);
    } catch (error) {
      actual = error;
    }
    return actual;
  };

  it('reads the Record from its anchors', async () => {
    await attachmentRemove(removeOptions({ attachmentId: 'attA' }));

    expect(__.recordRead).toHaveBeenCalledWith({
      baseId: 'appDEVREL123',
      tableId: 'Meetups',
      recordId: 'recABC',
    });
  });

  it.each([
    {
      title: 'one Attachment',
      attachmentId: 'attA',
      kept: ['attB', 'attC'],
    },
    {
      title: 'several Attachments',
      attachmentId: ['attA', 'attC'],
      kept: ['attB'],
    },
  ])('removes $title and keeps the others', async ({ attachmentId, kept }) => {
    await attachmentRemove(removeOptions({ attachmentId }));

    expect(__.recordUpdate).toHaveBeenCalledWith({
      baseId: 'appDEVREL123',
      tableId: 'Meetups',
      recordId: 'recABC',
      content: { Logo: kept.map((id) => ({ id })) },
    });
  });

  it('removes every Attachment with all', async () => {
    await attachmentRemove(removeOptions({ all: true }));

    expect(__.recordUpdate).toHaveBeenCalledWith({
      baseId: 'appDEVREL123',
      tableId: 'Meetups',
      recordId: 'recABC',
      content: { Logo: [] },
    });
  });

  it('returns the updated Record', async () => {
    const actual = await attachmentRemove(
      removeOptions({ attachmentId: 'attA' }),
    );

    expect(actual).toEqual(updated);
  });

  it('throws and changes nothing when an Attachment is not in the Field', async () => {
    const actual = await catchError(
      removeOptions({ attachmentId: ['attA', 'attZ'] }),
    );

    expect(actual).toHaveProperty('code', 'AIRTABLE_ATTACHMENT_NOT_IN_FIELD');
    expect(actual).toHaveProperty(
      'message',
      'Attachment not in Field Logo: attZ',
    );
    expect(__.recordUpdate).not.toHaveBeenCalled();
  });

  it.each([
    {
      title: 'Field',
      options: { field: undefined, attachmentId: 'attA' },
      code: 'AIRTABLE_FIELD_MISSING',
    },
    {
      title: 'Attachment',
      options: {},
      code: 'AIRTABLE_ATTACHMENT_ID_MISSING',
    },
    {
      title: 'choice between Attachments and all',
      options: { attachmentId: 'attA', all: true },
      code: 'AIRTABLE_ATTACHMENT_ID_CONFLICT',
    },
  ])(
    'throws before any call on a missing $title',
    async ({ options, code }) => {
      const actual = await catchError(removeOptions(options));

      expect(actual).toHaveProperty('code', code);
      expect(__.recordRead).not.toHaveBeenCalled();
      expect(__.recordUpdate).not.toHaveBeenCalled();
    },
  );

  it('surfaces the failure of the API for an unknown Record', async () => {
    __.recordRead.mockImplementation(() => {
      throw firostError('AIRTABLE_REQUEST_FAILED', 'NOT_FOUND');
    });

    const actual = await catchError(
      removeOptions({ recordId: 'recMISSING', attachmentId: 'attA' }),
    );

    expect(actual).toHaveProperty('code', 'AIRTABLE_REQUEST_FAILED');
  });

  it('surfaces the failure of the API for an unknown Field', async () => {
    __.recordUpdate.mockImplementation(() => {
      throw firostError('AIRTABLE_REQUEST_FAILED', 'UNKNOWN_FIELD_NAME');
    });

    const actual = await catchError(
      removeOptions({ field: 'Nope', all: true }),
    );

    expect(actual).toHaveProperty('code', 'AIRTABLE_REQUEST_FAILED');
  });
});
