# Skill: Create Tests

Use this skill when adding or updating tests for code in this repository.

## Preparation

1. Read `.ai/project/architecture.md` and `.ai/project/coding-standards.md`.
2. Identify the code under test and its public interface.
3. Locate existing tests for the feature or layer to match conventions.

## Test Strategy

### Unit Tests

- Test business logic in Blocs, Cubits, use cases, and repositories.
- Mock dependencies using the project's mocking approach.
- Cover success, failure, and edge cases.
- Avoid testing framework internals or private implementation details.

### Widget Tests

- Test important UI flows and user interactions.
- Pump the widget tree with required dependencies and localization.
- Verify that the correct widgets appear, disappear, or update in response to state changes.

### Integration Tests

- Use for end-to-end flows that span multiple features.
- Keep integration tests focused and deterministic.
- Avoid relying on external services; use test doubles where possible.

## Test Organization

- Mirror the `lib/` structure under `test/`.
- Name test files with the `_test.dart` suffix.
- Group related tests with `group()` and use descriptive test names.
- Follow the Given-When-Then or Arrange-Act-Assert pattern in test names.

## Test Quality

- Each test should verify one concept.
- Avoid shared mutable state between tests.
- Use `setUp` and `tearDown` for common fixtures and cleanup.
- Prefer `expect` assertions that are precise and readable.
- Do not write tests that pass trivially or duplicate production logic.

## Coverage Goals

- Aim for meaningful coverage of business logic and public APIs.
- Do not chase arbitrary coverage percentages at the expense of test quality.
- Cover error paths and boundary conditions.

## Verification

- Run the full test suite and fix any failures.
- Run static analysis and ensure no warnings were introduced.
- Review tests for clarity and maintainability.
