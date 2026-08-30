import { redactSecrets } from '../__lib/redactSecrets.js';

describe('redactSecrets', () => {
  describe('with API keys', () => {
    it('redacts long unspaced strings in diff lines', () => {
      const input = [
        'diff --git a/.env b/.env',
        '+export ANTHROPIC_KEY="sk-ant-api03-abcdef123456abcdef123456abcdef123456abcdef"',
      ].join('\n');

      const actual = redactSecrets(input);

      const expected = [
        'diff --git a/.env b/.env',
        '+export ANTHROPIC_KEY="REDACTED_REDACTED_REDACTED_REDACTED_REDACTED_REDACTED_R"',
      ].join('\n');
      expect(actual).toEqual(expected);
    });
  });

  describe('with normal code', () => {
    it('leaves short tokens unchanged', () => {
      const input = [
        'diff --git a/src/app.js b/src/app.js',
        '+const foo = bar(baz);',
        '+import { something } from "module";',
      ].join('\n');

      const actual = redactSecrets(input);

      expect(actual).toEqual(input);
    });

    it('leaves diff headers unchanged even if long', () => {
      const input = [
        'diff --git a/very/long/path/to/some/deeply/nested/file.js b/very/long/path/to/some/deeply/nested/file.js',
        '--- a/very/long/path/to/some/deeply/nested/file.js',
        '+++ b/very/long/path/to/some/deeply/nested/file.js',
        '+const x = 1;',
      ].join('\n');

      const actual = redactSecrets(input);

      expect(actual).toEqual(input);
    });
  });

  describe('with multiple secrets', () => {
    it('redacts all secret-looking values', () => {
      const input = [
        'diff --git a/.env b/.env',
        '+ANTHROPIC_KEY=sk-ant-api03-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        '+OPENAI_KEY=sk-proj-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
      ].join('\n');

      const actual = redactSecrets(input);

      const expected = [
        'diff --git a/.env b/.env',
        '+ANTHROPIC_KEY=REDACTED_REDACTED_REDACTED_REDACTED_REDACTED_REDACTED',
        '+OPENAI_KEY=REDACTED_REDACTED_REDACTED_REDACTED_REDACTED_RED',
      ].join('\n');
      expect(actual).toEqual(expected);
    });
  });

  describe('replacement format', () => {
    it('replaces with REDACTED of similar length', () => {
      const input =
        '+KEY="sk-ant-api03-abcdef123456abcdef123456abcdef123456abcdef"';

      const actual = redactSecrets(input);

      expect(actual).toEqual(
        '+KEY="REDACTED_REDACTED_REDACTED_REDACTED_REDACTED_REDACTED_R"',
      );
    });
  });

  describe('structure preservation', () => {
    it('preserves diff structure: filenames, line numbers, context lines', () => {
      const input = [
        'diff --git a/.env b/.env',
        'index abc1234..def5678 100644',
        '--- a/.env',
        '+++ b/.env',
        '@@ -1,3 +1,4 @@',
        ' EXISTING_VAR=hello',
        '+SECRET_TOKEN=aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff',
        ' OTHER_VAR=world',
      ].join('\n');

      const actual = redactSecrets(input);

      const expected = [
        'diff --git a/.env b/.env',
        'index abc1234..def5678 100644',
        '--- a/.env',
        '+++ b/.env',
        '@@ -1,3 +1,4 @@',
        ' EXISTING_VAR=hello',
        '+SECRET_TOKEN=REDACTED_REDACTED_REDACTED_REDACTED_REDACTED_RED',
        ' OTHER_VAR=world',
      ].join('\n');
      expect(actual).toEqual(expected);
    });

    it('preserves rename and binary fallback blocks', () => {
      const input = [
        'diff --git a/.env b/.env',
        '+TOKEN=aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff',
        '',
        'Files renamed:',
        '- old/path.js → new/path.js',
        '',
        'Binary files added:',
        '- image.png',
      ].join('\n');

      const actual = redactSecrets(input);

      const expected = [
        'diff --git a/.env b/.env',
        '+TOKEN=REDACTED_REDACTED_REDACTED_REDACTED_REDACTED_RED',
        '',
        'Files renamed:',
        '- old/path.js → new/path.js',
        '',
        'Binary files added:',
        '- image.png',
      ].join('\n');
      expect(actual).toEqual(expected);
    });
  });

  describe('edge cases', () => {
    it('returns empty string for empty input', () => {
      const actual = redactSecrets('');

      expect(actual).toEqual('');
    });

    it('does not redact long paths in diff headers', () => {
      const input = [
        'diff --git a/tools/term/zsh/config/functions/autoload/git/commit/__lib/getDiff.js b/tools/term/zsh/config/functions/autoload/git/commit/__lib/getDiff.js',
        '--- a/tools/term/zsh/config/functions/autoload/git/commit/__lib/getDiff.js',
        '+++ b/tools/term/zsh/config/functions/autoload/git/commit/__lib/getDiff.js',
      ].join('\n');

      const actual = redactSecrets(input);

      expect(actual).toEqual(input);
    });

    it('does not redact long URLs', () => {
      const input =
        '+const url = "https://api.example.com/v1/very/long/path/to/resource/endpoint";';

      const actual = redactSecrets(input);

      expect(actual).toEqual(input);
    });
  });
});
