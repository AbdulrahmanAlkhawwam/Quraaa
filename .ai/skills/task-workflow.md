# Skill: Task Workflow

Use this skill to execute a coding task from start to finish in this repository.

## Before You Start

1. Read the project documentation in `.ai/project/`:
   - `architecture.md`
   - `coding-standards.md`
   - `workflow.md`

2. Confirm you understand the requirement and acceptance criteria.

## Execution Steps

Follow the repository's standard development lifecycle:

1. **Understand the task** — capture the goal and acceptance criteria.
2. **Inspect the existing implementation** — explore relevant code, tests, and conventions.
3. **Plan the solution** — decide layer responsibilities, interfaces, DI, and tests.
4. **Implement the code** — make incremental, focused changes.
5. **Self-review** — re-read the diff for errors and clarity.
6. **Refactor** — remove duplication and simplify.
7. **Verify architecture compliance** — preserve Clean Architecture and feature-first structure.
8. **Verify localization** — no hardcoded user-facing strings.
9. **Verify design system usage** — use tokens and shared widgets.
10. **Verify dependency injection** — register and inject abstractions.
11. **Verify state management** — keep logic in Blocs/Cubits.
12. **Generate tests** — add meaningful unit, widget, or integration tests.
13. **Run a final review** — lint, format, run tests, and remove unrelated changes.
14. **Deliver** — summarize changes and verification steps.

## Constraints

- Project rules in `.ai/project/` override this skill.
- Keep changes minimal and focused on the task.
- Never introduce a different architecture or state management solution.
