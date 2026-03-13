# Project Documentation

This folder is the team-facing documentation for developing and maintaining `__APP_NAME__`.

## Recommended reading order

1. `onboarding.md`
2. `architecture.md`
3. `bootstrap.md`
4. `localization.md`
5. `auth-and-access-control.md`
6. `feature-development-playbook.md`
7. `usecases.md`
8. `router-service.md`
9. `workspace-automation.md`
10. `firebase-and-signing.md`
11. `testing-and-release-checklist.md`
12. `team-collaboration.md`

## Document map

- `onboarding.md`
  - Local setup, workspace commands, run modes, day-1 checklist.
- `architecture.md`
  - Package boundaries, Clean Architecture rules, data and startup flow.
- `bootstrap.md`
  - Startup flow, why bootstrap exists, and how to add startup tasks.
- `localization.md`
  - l10n setup, file layout, and formatting helpers.
- `auth-and-access-control.md`
  - Auth module design, event/state flow, and route guarding.
- `feature-development-playbook.md`
  - How to implement a new feature from data to UI, with coding patterns used in this project.
- `usecases.md`
  - Domain layer use case contracts, examples, and usage patterns.
- `router-service.md`
  - Navigation helpers, passing arguments/providers, and RouterExtras usage.
- `workspace-automation.md`
  - Workspace scripts, Makefile shortcuts, and CI command recommendations.
- `firebase-and-signing.md`
  - Flavor-specific Firebase files, Android/iOS signing setup, and CI release secret mapping.
- `testing-and-release-checklist.md`
  - Test strategy, quality gates, PR checklist, and troubleshooting notes.
- `team-collaboration.md`
  - Team workflow, PR quality expectations, and junior/senior collaboration model.

## Fast commands

```bash
flutter pub get
flutter analyze
flutter test
```

Per package (examples):

```bash
flutter test packages/app_network
flutter analyze packages/app_network/lib packages/app_network/test
```
