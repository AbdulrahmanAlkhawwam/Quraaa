# Skill: Code Review

Use this skill when reviewing a pull request, diff, or implementation change in this repository.

## Preparation

1. Read the project documentation:
   - `.ai/project/architecture.md`
   - `.ai/project/coding-standards.md`
   - `.ai/project/workflow.md`

2. Understand the purpose of the change and the acceptance criteria.

## Review Checklist

### Correctness

- [ ] The change implements the stated requirement.
- [ ] Edge cases and error paths are handled.
- [ ] No logic errors or regressions are introduced.

### Architecture

- [ ] Clean Architecture layering is preserved.
- [ ] Business logic remains in Blocs/Cubits, not widgets.
- [ ] Dependencies are injected, not instantiated in the UI.

### Code Quality

- [ ] Code follows SOLID, DRY, KISS, YAGNI, and Clean Code principles.
- [ ] Naming is clear and consistent with the codebase.
- [ ] Functions and widgets are small and focused.
- [ ] Duplication is avoided or refactored.

### Localization

- [ ] No hardcoded user-facing strings.
- [ ] New localization keys follow existing conventions.

### Design System

- [ ] No hardcoded colors, typography, spacing, radius, or shadows.
- [ ] Existing shared widgets are reused when possible.

### Testing

- [ ] Meaningful tests are added or updated for the changed logic.
- [ ] Tests cover success, failure, and edge cases where relevant.

### Security

- [ ] No secrets, tokens, or API URLs are hardcoded.
- [ ] Sensitive data is not logged or exposed.

### Scope

- [ ] The change is minimal and focused.
- [ ] No unrelated modifications are included.

## Review Output

Provide concrete, actionable feedback:

- Highlight specific issues with file and line references when possible.
- Suggest improvements or alternatives.
- Acknowledge what is done well.
- Summarize whether the change is ready to merge, needs minor revisions, or requires significant rework.
