# Quraaa Flutter Development Standards

This repository follows a production-ready Flutter architecture.

## Architecture

- Follow Clean Architecture.
- Keep Presentation, Domain and Data layers separated.
- Follow Feature-First folder structure.
- Respect the existing project architecture.
- Never introduce a different architecture.

## State Management

- Use `flutter_bloc`.
- Business logic belongs inside Cubits or Blocs.
- UI must never contain business logic.

## Bloc Logic Conventions

Follow the single-state class pattern used across the project (e.g., `AuthBloc`):

- Define one immutable `State` class per Bloc with a `status` enum (`init`, `loading`, `success`, `error`, plus navigation-specific values when needed).
- Provide a `copyWith` method on the state to emit incremental updates.
- Avoid sealed state sub-classes such as `AuthLoading`, `AuthSuccess`, etc.
- Events are simple immutable classes declared without `EquatableMixin`.
- Use `part 'bloc_event.dart'` and `part 'bloc_state.dart'` inside the Bloc file.
- Import `package:meta/meta.dart` and annotate events and state with `@immutable`.
- UI must read status and data directly from the Bloc state; do not cache loading or derived values in local widget variables.

## Dependency Injection

- Register dependencies using the existing DI solution.
- Never instantiate repositories or services directly inside UI.

## Localization

- Every user-facing string must be localized.
- Never hardcode strings.
- Use the existing localization system.

## Theming

Never hardcode:

- Colors
- Font sizes
- Font weights
- Border radius
- Spacing
- Shadows

Always use:

- `AppColors`
- `AppTypography`
- `AppRadius`
- `AppSpacing`
- Existing design tokens

## Components

Reuse existing shared widgets whenever possible.

Avoid duplicate components.

## Environment

Read secrets from `.env`.

Never hardcode:

- API URLs
- Tokens
- Secrets

## Code Quality

- Keep code modular.
- Use meaningful names.
- Follow existing naming conventions.
- Avoid duplicate code.
- Prefer extension methods when appropriate.
- Prefer const constructors.

## Output Requirements

Every generated implementation must:

- Preserve the existing architecture.
- Avoid unrelated modifications.
- Be production-ready.
