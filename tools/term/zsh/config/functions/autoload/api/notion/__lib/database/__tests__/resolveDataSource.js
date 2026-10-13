import { __, resolveDataSource } from '../resolveDataSource.js';

describe('resolveDataSource', () => {
  it('reads the single data source of the Database', async () => {
    const dataSource = { id: 'dsA', properties: {} };
    vi.spyOn(__, 'callApi').mockReturnValue(dataSource);

    const actual = await resolveDataSource({
      data_sources: [{ id: 'dsA', name: 'Meetups' }],
    });

    expect(__.callApi).toHaveBeenCalledWith('data_sources/dsA');
    expect(actual).toEqual(dataSource);
  });
});
