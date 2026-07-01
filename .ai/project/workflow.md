# Development Workflow

This workflow defines the standard lifecycle for implementing any change in this repository. Follow it incrementally to produce maintainable, production-ready code.

## 1. Understand the Task

- Read the requirement, issue, or specification carefully.
- Identify the acceptance criteria and expected behavior.
- Ask clarifying questions if anything is ambiguous.

## 2. Inspect the Existing Implementation

- Explore the relevant feature folders under `lib/features/`.
- Read existing Blocs/Cubits, repositories, use cases, and UI.
- Check tests under `test/` to understand current coverage and conventions.
- Look for shared widgets, extension methods, and utilities that can be reused.

## 3. Plan the Solution

- Decide which layers need changes: Presentation, Domain, Data, or shared code.
- Define the public interfaces first.
- Identify dependencies to register in the DI container.
- Outline the tests needed to verify the change.

## 4. Implement the Code

- Write code incrementally and in small, reviewable units.
- Keep business logic in Blocs/Cubits, not widgets.
- Use existing design tokens, components, and localization patterns.
- Follow the project's naming conventions and folder structure.

## 5. Self-Review

- Re-read the changed files before moving on.
- Check for typos, dead code, and leftover comments.
- Verify that the implementation matches the acceptance criteria.

## 6. Refactor Where Appropriate

- Remove duplication.
- Simplify complex functions or widgets.
- Improve naming without changing behavior.
- Ensure each class and function has a single responsibility.

## 7. Verify Architecture Compliance

- Confirm Clean Architecture layering is preserved.
- Ensure UI depends on abstractions, not concrete implementations.
- Verify no business logic leaked into widgets.

## 8. Verify Localization

- Confirm every user-facing string is localized.
- Remove any hardcoded strings from the UI.
- Add new keys to the existing localization files.

## 9. Verify Design System Usage

- Replace hardcoded colors, typography, spacing, radius, and shadows with design tokens.
- Reuse existing shared widgets where possible.
- Confirm visual consistency with the rest of the app.

## 10. Verify Dependency Injection

- Register new repositories, services, and data sources in the DI container.
- Inject abstractions into Blocs/Cubits and UI.
- Ensure no direct instantiation of dependencies inside widgets.

## 11. Verify State Management

- Use `flutter_bloc` correctly for the feature.
- Separate events/states clearly.
- Avoid deriving state inside the UI; keep state derivation in the Bloc/Cubit.

## 12. Generate Tests

- Add unit tests for business logic and repositories.
- Add widget tests for important UI flows.
- Add integration tests where appropriate.
- Aim for meaningful coverage, not arbitrary percentages.

## 13. Run a Final Review

- Run static analysis and formatting checks.
- Execute the test suite and fix failures.
- Review the diff one last time for unrelated changes.
- Confirm the change is minimal and focused.

## 14. Deliver the Completed Implementation

- Summarize what changed and why.
- Note any follow-up work or risks.
- Provide instructions for verifying the change.
