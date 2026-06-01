## TLDR

Update GLOSSARY.md to define the three Layer 3 hook outcomes: auto-approve, ask, escalate.

## What to build

Replace the current Layer 3 section of GLOSSARY.md. The existing two-term vocabulary (auto-approve / ask user) is replaced by three terms that precisely describe when each outcome occurs and what the user sees.

**New Layer 3 terms:**

| Term | Condition | User sees |
|------|-----------|-----------|
| **auto-approve** | Solkan allows | No dialog — command executes immediately |
| **ask** | Solkan rejects multiple binaries, OR single binary seen for the first time in this session | 2-option dialog (Allow / Deny) with rejected binary name(s) |
| **escalate** | Solkan rejects a single binary already seen in this session | 3-option dialog (Allow / Allow for session / Deny) without reason |

Replace the "4 cases" table (Solkan × RTK) with a "3 outcomes" table listing conditions for each outcome. The RTK dimension (rewrite / ignore) applies orthogonally to all three outcomes and can be noted as such.

## Acceptance criteria

- [ ] GLOSSARY.md Layer 3 contains exactly three terms: auto-approve, ask, escalate
- [ ] Each term documents the `permissionDecision` value it maps to (`allow`, `ask`, `defer`)
- [ ] Each term documents what the user sees in the dialog
- [ ] Each term documents the condition that triggers it
- [ ] The "4 cases" table is replaced by a "3 outcomes" description
- [ ] RTK's orthogonal role is preserved in the glossary
