import { __, scenarioMessages } from '../scenarioMessages.js';

describe('scenarioMessages', () => {
  it.each([
    {
      title: 'strings',
      messages: ['Module 1 is broken'],
      expected: ['Module 1 is broken'],
    },
    {
      title: 'objects as JSON',
      messages: [{ code: 'IM007' }],
      expected: ['{"code":"IM007"}'],
    },
    { title: 'nothing', messages: undefined, expected: [] },
  ])('lists $title', async ({ messages, expected }) => {
    vi.spyOn(__, 'callApi').mockReturnValue({
      response: { blueprint: { metadata: { designer: { messages } } } },
    });

    const actual = await scenarioMessages(925);

    expect(__.callApi).toHaveBeenCalledWith('scenarios/925/blueprint');
    expect(actual).toEqual(expected);
  });
});
