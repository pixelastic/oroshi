import { renderMermaid } from '../renderMermaid.js';

describe('renderMermaid', () => {
  const theme = {
    background: '#0c0f15',
    foreground: '#d1d5db',
    accent: '#3182ce',
    line: '#6b7280',
    muted: '#9ca3af',
  };
  const input = 'flowchart TD\n  A[Start] --> B[End]';

  it('returns an SVG string', () => {
    const actual = renderMermaid(input, theme);

    expect(actual).toContain('<svg');
  });

  it.each([
    { title: 'background', expected: theme.background },
    { title: 'foreground', expected: theme.foreground },
  ])('contains the theme $title color', ({ expected }) => {
    const actual = renderMermaid(input, theme);

    expect(actual).toContain(expected);
  });

  it.each([{ pattern: 'var(' }, { pattern: 'color-mix' }])(
    'resolves every "$pattern" to a hex color',
    ({ pattern }) => {
      const actual = renderMermaid(input, theme);

      expect(actual).not.toContain(pattern);
    },
  );

  it('adds an opaque rect filled with the theme background', () => {
    const actual = renderMermaid(input, theme);

    expect(actual).toMatch(
      new RegExp(
        `<rect x="[\\d.-]+" y="[\\d.-]+" width="[\\d.]+" height="[\\d.]+" fill="${theme.background}"/>`,
      ),
    );
  });

  it('sets numeric width and height on the root svg', () => {
    const actual = renderMermaid(input, theme);

    const rootTag = actual.match(/<svg[^>]*>/)[0];
    expect(rootTag).toMatch(/\swidth="[\d.]+"/);
    expect(rootTag).toMatch(/\sheight="[\d.]+"/);
  });

  it('throws on invalid Mermaid syntax', () => {
    let actual = null;
    try {
      renderMermaid('this is not mermaid', theme);
    } catch (error) {
      actual = error;
    }

    expect(actual).toBeInstanceOf(Error);
  });
});
