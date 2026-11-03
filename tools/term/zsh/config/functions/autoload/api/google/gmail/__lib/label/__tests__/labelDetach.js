import { firostError } from 'firost';
import { __, labelDetach } from '../labelDetach.js';

describe('labelDetach', () => {
  beforeEach(() => {
    vi.spyOn(__, 'resolveLabel').mockReturnValue('Label_1');
    vi.spyOn(__, 'modifyLabels').mockReturnValue({ id: 't1' });
  });

  it('removes the id of the label from the Thread and prints the threadId and name', async () => {
    const actual = await labelDetach({ threadId: 't1', name: 'Work' });

    expect(__.resolveLabel).toHaveBeenCalledWith('Work');
    expect(__.modifyLabels).toHaveBeenCalledWith({
      threadId: 't1',
      remove: ['Label_1'],
    });
    expect(actual).toEqual({ threadId: 't1', name: 'Work' });
  });

  it('gives the same result when repeated', async () => {
    const first = await labelDetach({ threadId: 't1', name: 'Work' });
    const second = await labelDetach({ threadId: 't1', name: 'Work' });

    expect(second).toEqual(first);
  });

  it('fails with GMAIL_THREAD_ID_MISSING when the threadId is missing, with no API call', async () => {
    let actual = null;
    try {
      await labelDetach({ name: 'Work' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_THREAD_ID_MISSING');
    expect(__.modifyLabels).not.toHaveBeenCalled();
  });

  it('fails with GMAIL_LABEL_NOT_FOUND when the label is missing, with no change', async () => {
    __.resolveLabel.mockImplementation(() => {
      throw firostError('GMAIL_LABEL_NOT_FOUND', 'Label Work not found');
    });

    let actual = null;
    try {
      await labelDetach({ threadId: 't1', name: 'Work' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_LABEL_NOT_FOUND');
    expect(__.modifyLabels).not.toHaveBeenCalled();
  });
});
