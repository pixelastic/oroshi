import { resolveColors } from '../resolveColors.js';

describe('resolveColors', () => {
  const colors = {
    boolean: { hex: '#f59e0b' },
    keyword: { hex: '#38a169' },
  };

  it('resolves each color name to its hex value', () => {
    const input = {
      keyword: 'keyword',
      _storage: 'keyword',
      literal: 'boolean',
    };
    const actual = resolveColors(input, colors);
    expect(actual).toEqual({
      keyword: '#38a169',
      _storage: '#38a169',
      literal: '#f59e0b',
    });
  });

  it('throws on unknown color names', () => {
    let actual = null;
    try {
      resolveColors({ keyword: 'nope' }, colors);
    } catch (error) {
      actual = error;
    }
    expect(actual).toHaveProperty('code', 'CLAUDE_SYNTAX_PATCH_UNKNOWN_COLOR');
    expect(actual).toHaveProperty(
      'message',
      'Unknown color "nope" for "keyword"',
    );
  });
});
