# Coding Standards

This guide defines the engineering principles and language-specific practices used throughout the repository.

## Core Principles

### SOLID

- **Single Responsibility Principle:** A class, function, or widget should do one thing and do it well.
- **Open/Closed Principle:** Be open for extension, closed for modification.
- **Liskov Substitution Principle:** Subtypes must be substitutable for their base types without altering correctness.
- **Interface Segregation Principle:** Prefer small, focused contracts over large general-purpose ones.
- **Dependency Inversion Principle:** Depend on abstractions, not concrete implementations.

Apply SOLID by separating UI, business logic, and data access into distinct layers and injecting dependencies through abstractions.

### DRY (Don't Repeat Yourself)

- Extract duplicated logic into reusable functions, widgets, or services.
- Share common UI patterns through existing shared components.
- Avoid copying and pasting code across features.

### KISS (Keep It Simple, Stupid)

- Prefer the simplest solution that meets the requirement.
- Avoid over-engineering, premature abstraction, and unnecessary indirection.
- Favor readability and maintainability over cleverness.

### YAGNI (You Aren't Gonna Need It)

- Do not implement features or abstractions that are not required now.
- Add complexity only when a real need emerges.

### Clean Code

- Use meaningful, intention-revealing names.
- Keep functions and widgets small and focused.
- Minimize nesting and reduce cognitive load.
- Write self-documenting code; comments should explain *why*, not *what*.
- Handle errors explicitly and close resources properly.

## Flutter Best Practices

- Use `flutter_bloc` for state management; keep business logic out of widgets.
- Prefer `const` constructors and widgets to reduce rebuilds.
- Build responsive layouts using layout builders, constraints, and design tokens.
- Separate reusable UI into shared widgets under `lib/shared/` or the appropriate feature folder.
- Use the existing navigation, theming, and localization systems.
- Avoid hardcoding values; always reference design tokens.

## Dart Best Practices

- Follow the official Dart style guide and the project's `analysis_options.yaml`.
- Use `final` and `const` where possible.
- Prefer null safety patterns and explicit null checks.
- Use `async/await` instead of raw `Future` chains for readability.
- Avoid dynamic typing; prefer strong types and sealed classes where appropriate.
- Leverage extension methods for small, reusable behavior additions.

## Error Handling

- Handle errors at the appropriate layer.
- Use explicit result or failure types for domain errors.
- Never silently swallow exceptions; log or report them.
- Show user-friendly, localized error messages in the UI.
- Fail fast and provide actionable feedback.

## Logging

- Use the project's logging solution consistently.
- Avoid `print`; use the provided logger.
- Log at appropriate levels: debug for development, error for failures, info for milestones.
- Never log secrets, tokens, or personally identifiable information.

## Folder Organization

- Feature-first folder structure under `lib/features/`.
- Clean Architecture layers: `presentation/`, `domain/`, and `data/` inside each feature where applicable.
- Shared code lives in `lib/shared/` or `lib/core/`.
- Configuration, routing, and DI setup live in `lib/config/` and `lib/app/`.
- Keep tests mirror the `lib/` structure under `test/`.

## Naming Conventions

- Files and folders: `snake_case`.
- Classes and enums: `PascalCase`.
- Variables, functions, and parameters: `camelCase`.
- Constants: `camelCase` or `kConstantName` if the project already uses that style; stay consistent.
- Widgets: descriptive names ending in the widget type, e.g., `UserProfileCard`.
- Blocs/Cubits: `FeatureBloc` / `FeatureCubit`.
- Repositories: `FeatureRepository` or `FeatureRepositoryImpl` for implementations.

## Performance

- Prefer `const` widgets and constructors.
- Avoid unnecessary rebuilds; use selectors and `BlocListener`/`BlocBuilder` efficiently.
- Lazy-load heavy resources and paginate large lists.
- Dispose controllers, listeners, and subscriptions.
- Profile before optimizing; target real bottlenecks.

## Accessibility

- Provide semantic labels for interactive widgets.
- Ensure sufficient color contrast and readable font sizes.
- Support screen readers and keyboard navigation where applicable.
- Test with the largest expected font sizes and screen zooms.

## Responsive UI

- Use `LayoutBuilder`, `MediaQuery`, and responsive design tokens.
- Avoid fixed pixel values; prefer relative spacing and constraints.
- Test layouts on multiple screen sizes and orientations.
- Adapt navigation patterns for tablets and desktops when supported.

## Documentation Expectations

- Document public APIs and complex business logic.
- Keep README files in each major directory up to date.
- Use inline comments sparingly and only when the code cannot explain itself.
- Update this workspace when conventions change.

## Security Practices

- Read secrets from `.env` and the project's environment configuration.
- Never commit API keys, tokens, or credentials.
- Validate and sanitize external input.
- Use secure storage for sensitive user data.
- Apply least privilege for permissions and network requests.
- Keep dependencies up to date and review third-party packages before adding them.
