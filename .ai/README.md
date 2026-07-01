# AI Workspace

This directory contains reusable project documentation and task skills for anyone contributing to this repository—human or AI coding assistant.

## Purpose

The AI workspace centralizes the project's architecture rules, coding standards, and development workflow so that every implementation stays consistent with the existing codebase. It reduces onboarding time and helps contributors produce production-ready code that respects the repository's conventions.

## How to Use It

1. **Read the project documentation first.** Before writing or modifying code, review the files under [`project/`](project/):
   - [`architecture.md`](project/architecture.md) — structural rules, layers, state management, and design system.
   - [`coding-standards.md`](project/coding-standards.md) — engineering principles and Flutter/Dart best practices.
   - [`workflow.md`](project/workflow.md) — the standard development lifecycle.

2. **Pick a relevant skill.** When a task maps to a specific activity, follow the guidance in [`skills/`](skills/):
   - [`task-workflow.md`](skills/task-workflow.md) — generic step-by-step execution.
   - [`code-review.md`](skills/code-review.md) — reviewing a pull request or diff.
   - [`review.md`](skills/review.md) — general review checklist for any change.
   - [`simplify.md`](skills/simplify.md) — reducing complexity without changing behavior.
   - [`create-tests.md`](skills/create-tests.md) — adding automated tests.

3. **Apply project rules before skill files.** The documentation in [`project/`](project/) always takes precedence over the generic instructions in [`skills/`](skills/). If a skill conflicts with a project rule, follow the project rule.

## Priority

```text
Project rules (project/) > Skill files (skills/)
```

Every coding task must read the project documentation before implementation.

## Keeping This Workspace Current

When the project introduces new conventions, architectural changes, or tooling, update the corresponding files in this workspace so they remain accurate for future contributors.
