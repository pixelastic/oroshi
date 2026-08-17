## Guidance

- **Testing:** `bats tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`
- **Linting:** `bats-lint tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`
- **Hook under test:** `tools/ai/claude/config/hooks/preToolUse-Bash`
- **Solkan wrapper:** `tools/ai/claude/config/hooks/preToolUse-Bash-solkan.zsh` (sources real Solkan via `solkan` CLI)
- **Allowlist:** `tools/ai/claude/config/hooks/allowlist.json`
- **Rewrite list:** `tools/ai/claude/config/hooks/rewrite.json`
- **Test helpers:** `bats_mock`, `bats_run_zsh`, `expect_json`, `expect_json_null` (from `helper` library)
- **Integration tests** should NOT mock `preToolUse-Bash-solkan` — let the real function (from `preToolUse-Bash-solkan.zsh`) call real `solkan`
- **Integration tests** should still mock `preToolUse-Bash-rtk` as an identity function — RTK is a separate concern
- **Existing mocked rewrite tests** use `bats_mock preToolUse-Bash-solkan preToolUse-Bash-rtk` — integration tests use `bats_mock preToolUse-Bash-rtk` (solkan only)

## Discoveries
