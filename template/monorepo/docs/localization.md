# Localization (l10n)

This project uses Flutter gen-l10n with ARB files for translations and `intl`
for date/number formatting.

## Files

- `l10n.yaml`: gen-l10n configuration.
- `lib/l10n/arb/app_en.arb`: English strings.
- `lib/l10n/arb/app_my.arb`: Myanmar strings.
- `lib/l10n/gen/*`: generated localizations (ignored by git via `lib/l10n/.gitignore`).
- `lib/l10n/l10n.dart`: `BuildContext` extension for `context.l10n`.
- `lib/l10n/formatters.dart`: locale-aware date and number formatting.
- `lib/app/config/app_locale_controller.dart`: persisted locale override.

## Wiring

- `MaterialApp.router` registers delegates and `supportedLocales`.
- `AppLocaleController` persists the selected language in `SharedPreferences`.
- Language selector lives in the More page (system default, `en`, `my`).

## Add or update strings

1. Add the key to `lib/l10n/arb/app_en.arb`.
2. Add the matching key to `lib/l10n/arb/app_my.arb`.
3. Run `flutter gen-l10n`.
4. Use in widgets with `context.l10n.<key>`.

Placeholder tips:

- Prefer String placeholders if you pre-format values (numbers, dates).
- Keep placeholder names consistent across locales.

## Formatting helpers

Use the shared helpers so formatting respects the active locale:

- `formatNumber(context, value)`
- `formatDateShort(context, value)`
- `formatDateRangeShort(context, start, end)`

Defined in `lib/l10n/formatters.dart`.

## Adding a new locale

1. Create a new ARB file (for example `app_th.arb`).
2. Run `flutter gen-l10n`.
3. Add the locale to the language selector.
4. Ensure fonts support the new script.

## Reset to system language

Select "Use device language" in the language dropdown. This clears the
persisted locale and falls back to the OS locale.
