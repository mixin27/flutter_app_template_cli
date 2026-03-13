# Team Collaboration Guide

## Branching

- Keep branches small and focused.
- Use feature-oriented branch names, for example:
  - `feature/auth-otp-screen`
  - `feature/coupon-claim-api`
  - `chore/docs-auth-strategy`

## Commit style

Use clear commit messages with scope:

- `feat(auth): add otp verify page`
- `fix(router): protect reward claim route`
- `docs(architecture): add feature playbook`

## PR expectations

Each PR should include:

- what changed
- why it changed
- screenshots/video for UI changes
- test evidence (`analyze` + `test`)
- risk notes (routing, DI, auth, migration)

## Junior/senior split recommendation

For each medium feature:

1. Senior defines domain contracts and acceptance criteria.
2. Junior implements data + presentation with tests.
3. Senior reviews DI/router/auth policy impact.
4. Junior updates docs and follows release checklist.

## Review checklist for risky areas

- `lib/app/di/injection_container.dart`
- `lib/app/di/modules/**`
- `lib/app/router/app_router.dart`
- `lib/features/auth/**`
- `packages/app_network/**`
- `lib/core/database/**`

## Communication cadence

- Post a short daily update with:
  - completed work
  - blockers
  - next task
- For API contract uncertainty, resolve first before coding UI details.
