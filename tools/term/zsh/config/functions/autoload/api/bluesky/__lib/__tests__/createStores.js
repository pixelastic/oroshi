import { readJson, remove, tmpDirectory } from 'firost';
import { createStores } from '../createStores.js';

describe('createStores', () => {
  let testDirectory;
  let path;
  beforeEach(() => {
    testDirectory = tmpDirectory('bluesky/createStores');
    path = `${testDirectory}/tokens.json`;
  });
  afterEach(async () => {
    await remove(testDirectory);
  });

  it('reads back what it saved, in the section of each store', async () => {
    const { stateStore, sessionStore } = createStores(path);

    await stateStore.set('state1', { iss: 'a' });
    await sessionStore.set('did:plc:abc', { token: 'b' });

    expect(await stateStore.get('state1')).toEqual({ iss: 'a' });
    expect(await sessionStore.get('did:plc:abc')).toEqual({ token: 'b' });
    expect(await readJson(path)).toEqual({
      states: { state1: { iss: 'a' } },
      sessions: { 'did:plc:abc': { token: 'b' } },
    });
  });

  it('returns undefined for an unknown key, without a tokens file', async () => {
    const { sessionStore } = createStores(path);

    const actual = await sessionStore.get('did:plc:abc');

    expect(actual).toBeUndefined();
  });

  it('deletes an entry and keeps the others', async () => {
    const { stateStore } = createStores(path);
    await stateStore.set('state1', 1);
    await stateStore.set('state2', 2);

    await stateStore.del('state1');

    expect(await readJson(path)).toEqual({ states: { state2: 2 } });
  });
});
