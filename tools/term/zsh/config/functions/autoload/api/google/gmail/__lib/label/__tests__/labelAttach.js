import { firostError } from 'firost';
import { __, labelAttach } from '../labelAttach.js';

describe('labelAttach', () => {
  beforeEach(() => {
    vi.spyOn(__, 'resolveLabel').mockReturnValue('Label_1');
    vi.spyOn(__, 'modifyLabels').mockReturnValue({ id: 't1' });
  });

  it('adds the id of the label to the Thread and prints the threadId and name', async () => {
    const actual = await labelAttach({ threadId: 't1', name: 'Work' });

    expect(__.resolveLabel).toHaveBeenCalledWith('Work');
    expect(__.modifyLabels).toHaveBeenCalledWith({
      threadId: 't1',
      add: ['Label_1'],
    });
    expect(actual).toEqual({ threadId: 't1', name: 'Work' });
  });

  it('gives the same result when repeated', async () => {
    const first = await labelAttach({ threadId: 't1', name: 'Work' });
    const second = await labelAttach({ threadId: 't1', name: 'Work' });

    expect(second).toEqual(first);
  });

  it('fails with GMAIL_THREAD_ID_MISSING when the threadId is missing, with no API call', async () => {
    let actual = null;
    try {
      await labelAttach({ name: 'Work' });
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
      await labelAttach({ threadId: 't1', name: 'Work' });
    } catch (error) {
      actual = error;
    }

    expect(actual).toHaveProperty('code', 'GMAIL_LABEL_NOT_FOUND');
    expect(__.modifyLabels).not.toHaveBeenCalled();
  });
});
