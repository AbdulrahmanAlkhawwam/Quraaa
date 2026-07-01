# Skill: Review

Use this skill to perform a general review of any code change, file, or feature in this repository.

## Scope

A review can apply to:

- A single file or diff.
- A feature implementation.
- A refactor or cleanup change.
- A test suite.

## Preparation

1. Read `.ai/project/architecture.md`, `.ai/project/coding-standards.md`, and `.ai/project/workflow.md`.
2. Understand the context and goals of the change.
3. Identify the files and layers involved.

## Review Dimensions

1. **Requirement fit** — Does the change solve the right problem?
2. **Architecture** — Does it respect Clean Architecture and the feature-first structure?
3. **State management** — Is business logic kept out of the UI?
4. **Dependency injection** — Are dependencies registered and injected correctly?
5. **Localization** — Are all user-facing strings localized?
6. **Design system** — Are tokens and shared widgets used consistently?
7. **Code quality** — Is the code clean, simple, and free of duplication?
8. **Tests** — Is the change adequately tested?
9. **Security** — Are secrets and sensitive data handled properly?
10. **Scope** — Is the change focused and minimal?

## Review Output

For each dimension, note:

- **Good** — what is done well.
- **Concern** — what needs attention.
- **Action** — specific recommendation or required change.

End with a clear verdict:

- **Approved** — ready as-is.
- **Approved with comments** — minor issues to address.
- **Needs changes** — significant issues must be resolved.

Be constructive and specific in every recommendation.
