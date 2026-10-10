# Localization (i18n)

BigPay uses Flutter's standard ARB-based localization (`flutter_localizations` +
`intl`, codegen via `flutter gen-l10n`, configured in `l10n.yaml` at the repo
root). Generated output lives in this folder (`app_localizations*.dart`) and
is committed like any other generated Dart — regenerate it whenever an `.arb`
file changes.

Currently supported locales: English (`en`, template/source of truth), German
(`de`), Spanish (`es`), French (`fr`), Arabic (`ar`), Nigerian/West African
Pidgin (`pcm`).

Arabic renders full RTL automatically — mirrored layout, right-aligned text,
flipped chevrons — with zero extra code, because the app already uses
standard directional Flutter widgets (`Row`, `ListTile`, icon-relative
positioning) rather than hardcoded `Alignment.centerLeft`/left-specific
`EdgeInsets`. Confirmed on a real simulator. If a future page is built with
literal left/right positioning instead of directional equivalents, it won't
mirror correctly — prefer `Alignment.centerStart`/`AlignmentDirectional`,
`EdgeInsetsDirectional`, etc. over left/right-specific APIs so this keeps
working.

## Changing existing wording

1. Edit the string's value in `app_en.arb` (the English text is what's shown
   to a translator/AI as the thing to translate — it's also the fallback for
   any locale missing a key).
2. Update the same key in `app_de.arb`, `app_es.arb`, `app_fr.arb` to match
   the new meaning. If you don't have translations ready, ask Claude Code:
   *"Update the `xyzKey` translations in lib/l10n/app_*.arb to say ... in
   German/Spanish/French."* — that's the same way every string in this file
   was translated.
3. Run `flutter gen-l10n` (or `flutter pub get`, which triggers it since
   `generate: true` is set in `pubspec.yaml`) to regenerate
   `app_localizations*.dart`.
4. `dart analyze` the files you touched.

Never hand-edit the generated `app_localizations*.dart` files — they're
overwritten on every `gen-l10n` run.

## Adding a new translatable string

1. Add the key to `app_en.arb` with an English value and a `@keyName`
   metadata block with a one-line `description` (this is what shows up for
   translators and keeps intent clear later). Reuse an existing key instead
   of adding a near-duplicate if the exact same English string is already
   used elsewhere for the same purpose (see the `common*` keys).
2. Add the same key with a translated value to each of `app_de.arb`,
   `app_es.arb`, `app_fr.arb` — no `@` metadata needed there, just the
   `"key": "value"` pair.
3. Run `flutter gen-l10n`.
4. In the page, `import 'package:bigpay/l10n/app_localizations.dart';` and
   replace the hardcoded literal with `AppLocalizations.of(context)!.keyName`
   (grab `final l10n = AppLocalizations.of(context)!;` once at the top of
   `build()` when a widget uses more than one or two strings).

For a string with a variable in it, use an ICU placeholder — see
`historyFilterActiveTooltip`/`historyNoMatchQuery` in `app_en.arb` for the
pattern (`"{name}"` in the value, a `"placeholders"` block in the `@key`
metadata with the parameter's `type`). The generated getter becomes a method
taking that argument, e.g. `l10n.historyFilterActiveTooltip(filterName)`.

## Adding a whole new language

1. Copy `app_en.arb` to `app_<code>.arb` (e.g. `app_it.arb` for Italian) and
   set `"@@locale"` to the new code.
2. Translate every value (drop the `@key` metadata blocks — they're
   English-file-only documentation, not needed in translated files). The
   fastest way: hand the whole `app_en.arb` file to Claude Code and ask it to
   produce the translated ARB for the target language — that's how German,
   Spanish, and French were bootstrapped in this project.
3. Add `Locale('<code>')` to `AppState.supportedLocales` in
   `lib/utils/app_state.util.dart`.
4. Run `flutter gen-l10n`.
5. The language picker on the More/Account page
   (`lib/ui/pages/more/more.pg.dart`, `_buildLanguageSwitcher` /
   `_openLanguagePicker`) picks up new locales automatically from
   `AppState.supportedLocales` — the one thing you must add by hand is the
   language's own name in `_languageNames` (the const map at the top of that
   file), since the picker shows each language in its own endonym
   ("Deutsch", "Español") rather than translated into whatever language the
   UI currently is — add `'<code>': '<Native Name>'` there too.

## Dynamic content

Two different things fall under "dynamic strings" — they need different
handling:

- **A variable inside an app-authored sentence** (a name, a search query, a
  count) — use an ICU placeholder in the ARB value, so the sentence structure
  is translated but the interpolated value isn't (translating someone's name
  or a search term would be wrong). See `historyFilterActiveTooltip` /
  `beneficiariesRemoveConfirm` in `app_en.arb` for the pattern; the generated
  getter becomes a method taking that argument.
- **Content that comes from the backend/CMS at runtime** — activity names,
  form field labels, complaint categories, backend error messages
  (`snapshot.error!.message`), the walkthrough slides' `title`/`description`,
  payee/beneficiary names — is **not** translated by this setup and can't be
  from the Flutter side; it's live data the server returns, not app
  vocabulary. Making that multi-language is a backend concern (the API would
  need to accept a locale — e.g. from `AppState.localeNotifier.value` — and
  return already-localized content). Out of scope for this client-side pass.

## Keeping translations in sync

The rule: **a string never lands in `lib/ui` without going through this
file** — no `Text('...')` literals, no hardcoded `label`/`title`/`tooltip`
params. Add the key to all 4 `.arb` files in the same change that introduces
the string, not as a follow-up.

Two backstops catch it if that rule slips:

- `flutter gen-l10n` (runs on every `flutter pub get`/build via
  `generate: true` in `pubspec.yaml`) prints a warning for any key present in
  `app_en.arb` but missing from a translated file — it doesn't fail the
  build (the generated getter falls back to the English string at runtime
  rather than crashing), so don't rely on merely *not noticing* an error;
  read the build output.
- `dart run tool/check_arb_parity.dart` — a small script (no dependencies)
  that diffs every key in the 3 translated files against `app_en.arb` and
  exits non-zero listing exactly what's missing or stale on either side.
  Wire this into CI (e.g. a step in the same job that runs `dart analyze`)
  so a key added to English without the other 3 locales fails the PR instead
  of shipping silently-English text. Run it locally any time after touching
  an `.arb` file.

A **wording change** to an existing key (not a new key) is invisible to both
of the above — the key still exists everywhere, just with stale meaning in 3
languages. There's no tooling shortcut for this: when you materially change
what an English string says, re-translate it in the other 3 files in the
same change (see "Changing existing wording" above).

## Backend awareness

Every API call's `meta` payload includes the effective language as
`meta.locale` (`AppState.effectiveLocaleCode`, set in
`MainRemote._formatRequestPayload` in `lib/data/remote/main.remote.dart`) —
the user's explicit choice, or the best system-locale match against
`AppState.supportedLocales` when they've left it on "Auto". This doesn't
translate anything by itself (see "Dynamic content" above) — it just tells
the backend what language the client is in, for whenever server-driven
content localization is built.

## Scope note

As of this pass, translated: all 14 auth-flow pages, dashboard, wallets,
history, beneficiaries, KYC, process flow (services/service/form/summary/
feedback), notifications, app error, walkthrough, the More/Account page
(including the language picker itself, now a bottom sheet — see "Adding a
whole new language" above), and shared components used across many pages
(`nav_items.dart`, `select_input.dart`, `payee_input.dart`,
`ghana_card_input.dart`, `virtual_wallet_card.dart`, `pin_auth.dart`/
`otp_auth.dart`, `otp_input.dart`, `message.util.dart`'s dialog defaults, the
"Back" tooltip shared across the three layout files). Verified live on an
iPad simulator, including the locale switching itself.

Not yet translated: anything not listed above — a genuinely small remainder
at this point. Extend the same way when it's next touched.
