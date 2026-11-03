import { firostError } from 'firost';
import { __, labelDelete } from '../labelDelete.js';

describe('labelDelete', () => {
  beforeEach(() => {
    vi.spyOn(__, 'resolveLabel').mockReturnValue('Label_1');
    vi.spyOn(__, 'callApi').mockReturnValue('');
  });

  it('deletes the label through the API and prints its id', async () => {
    const actual = await labelDelete({ name: 'Work' });

    expect(__.resolveLabel).toHaveBeenCalledWith('Work');
    expect(__.callApi).toHaveBeenCalledWith('labels/Label_1', {
      method: 'DELETE',
    });
    expect(actual).toEqual({ labelId: 'Label_1' });
  });

  it.each([
    { title: 'an unknown name', name: 'Nope' },
    { title: 'the name of a system label', name: 'INBOX' },
  ])(
    'fails with GMAIL_LABEL_NOT_FOUND for $title, with no API call',
    async ({ name }) => {
      __.resolveLabel.mockImplementation(() => {
        throw firostError('GMAIL_LABEL_NOT_FOUND', `Label ${name} not found`);
      });

      let actual = null;
      try {
        await labelDelete({ name });
      } catch (error) {
        actual = error;
      }

      expect(actual).toHaveProperty('code', 'GMAIL_LABEL_NOT_FOUND');
      expect(__.callApi).not.toHaveBeenCalled();
    },
  );
});
