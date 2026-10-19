import { formatScenario } from '../formatScenario.js';

describe('formatScenario', () => {
  const input = {
    id: 2353107,
    name: 'triggerCheck',
    teamId: 862420,
    hookId: 1130512,
    devices: [],
    folderId: 131246,
    slots: null,
    usedPackages: ['gateway', 'util'],
    lastEdit: '2026-02-26T14:24:01.044Z',
    scheduling: { type: 'immediately' },
    operations: null,
    dlqCount: 0,
    allDlqCount: 0,
    createdByUser: { id: 1, name: 'Tim', email: 'tim@example.com' },
    updatedByUser: { id: 1, name: 'Tim', email: 'tim@example.com' },
    nextExec: null,
    isActive: true,
    isinvalid: false,
    type: 'scenario',
  };

  it('keeps the listed fields only', () => {
    const actual = formatScenario(input);

    expect(actual).toEqual({
      id: 2353107,
      name: 'triggerCheck',
      folderId: 131246,
      isActive: true,
      isinvalid: false,
      scheduling: { type: 'immediately' },
      lastEdit: '2026-02-26T14:24:01.044Z',
      nextExec: null,
    });
  });

  it('keeps isinvalid when the Scenario is invalid', () => {
    const actual = formatScenario({ ...input, isinvalid: true });

    expect(actual).toHaveProperty('isinvalid', true);
  });

  it('drops the email of the users', () => {
    const actual = JSON.stringify(formatScenario(input));

    expect(actual).not.toContain('tim@example.com');
  });

  it('drops operations and dlqCount', () => {
    const actual = formatScenario(input);

    expect(actual).not.toHaveProperty('operations');
    expect(actual).not.toHaveProperty('dlqCount');
    expect(actual).not.toHaveProperty('allDlqCount');
  });
});
