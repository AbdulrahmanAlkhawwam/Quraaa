# Skill: Simplify Code

## Purpose

Refactor existing code to make it cleaner, simpler, easier to understand, easier to maintain, and more reusable without changing any behavior or project architecture.

The output must always remain functionally identical.

## When to Apply

- A function, widget, or class is hard to understand at a glance.
- There is nesting deeper than two or three levels.
- A single file or class has multiple responsibilities.
- Duplication can be extracted into a shared helper or widget.
- Comments explain *what* the code does instead of *why*.

## Preparation

1. Read `.ai/project/architecture.md` and `.ai/project/coding-standards.md`.
2. Understand the current behavior, inputs, outputs, and side effects.
3. Check existing tests to preserve coverage and behavior.

## Core Rules

Never change:

- Clean Architecture
- Feature-First structure
- `flutter_bloc` state management
- Dependency Injection
- Routing
- Localization
- Theme system
- API behavior
- Business logic
- Public interfaces unless explicitly requested

The only goal is improving code quality.

## Simplification Checklist

Review the code and improve it wherever possible.

### Remove Duplication

- Eliminate duplicated logic.
- Reuse existing helpers, widgets, extensions, services, and utilities.
- Never duplicate functionality.

### Improve Readability

- Prefer code that is easy to understand.
- Improve variable names, function names, widget names, class names, and file organization.
- Replace unclear code with expressive code.

### Reduce Complexity

Reduce unnecessary:

- `if` statements
- `else` blocks
- nested conditions
- `switch` statements
- temporary variables
- wrappers
- callbacks

Prefer early returns and guard clauses.
Reduce indentation whenever possible.

### Extract Reusable Code

Extract widgets, helper methods, extensions, utilities, and constants only when it genuinely improves readability. Do not over-engineer.

### Flutter Best Practices

Prefer:

- `const` constructors
- `final` variables
- immutable widgets
- `StatelessWidget` whenever possible

Remove:

- unnecessary `StatefulWidget`s
- unnecessary rebuilds
- unnecessary widget nesting

Improve widget composition.

### Performance

Reduce:

- unnecessary rebuilds
- repeated calculations
- repeated object creation
- repeated list generation

Cache values when appropriate. Avoid unnecessary work inside `build()`.

### Clean Architecture

Respect existing layers. Presentation must remain Presentation, Domain must remain Domain, and Data must remain Data.

Never move business logic into UI. Never move repository logic into Cubits. Never violate dependency direction.

### Design System

Do not hardcode colors, spacing, typography, radius, or shadows. Always reuse existing design tokens.

### Localization

Do not hardcode user-facing text. Keep all localization intact.

### Dependency Injection

Never instantiate services directly. Reuse existing dependency injection.

### Code Style

Follow existing project conventions. Prefer concise, expressive, self-documenting code.

Remove:

- dead code
- commented code
- unused imports
- unused variables
- unused methods
- duplicated models

## Constraints

- Do not change behavior unless explicitly requested.
- Keep public APIs stable when possible.
- Maintain or improve test coverage.
- Follow the project's conventions for naming, formatting, and structure.
- Avoid over-abstraction; simpler is better.

## Safety Rules

- Never simplify if it changes behavior.
- Never sacrifice readability just to reduce lines of code.
- Never introduce clever code that is harder to understand.
- Readable code is always preferred over shorter code.

## Before Finishing

Verify that:

- ✅ Behavior is unchanged.
- ✅ Architecture is unchanged.
- ✅ `flutter_bloc` usage is unchanged.
- ✅ Dependency Injection is unchanged.
- ✅ Localization still works.
- ✅ Theme usage is unchanged.
- ✅ No duplicated code remains.
- ✅ No dead code remains.
- ✅ Code is easier to understand.
- ✅ Code is easier to maintain.
- ✅ Existing project conventions are respected.

## Verification

- Run existing tests and confirm they still pass.
- Review the simplified code against the checklist in `.ai/skills/review.md`.
- Ensure no hardcoded strings, colors, or values were introduced.

## Output Format

Return a summary using the following format:

```text
Simplification Summary

Improvements Made
...

Code Quality Improvements
...

Performance Improvements
...

Readability Improvements
...

Reusability Improvements
...

Architecture Validation
- Clean Architecture preserved
- Feature-First preserved
- flutter_bloc preserved
- Dependency Injection preserved
- Localization preserved
- Design System preserved

Final Result
The code is production-ready, simpler, easier to maintain, and functionally identical to the original implementation.
```
