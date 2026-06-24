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
