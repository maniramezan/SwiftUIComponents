---
name: add-package-string
description: Add or change a user-facing string that the Components package owns (a default placeholder, an accessibility label/value/hint, a role name) with translations for every supported locale. Use whenever a component would otherwise hard-code English text.
---

# Add a package-owned string

Only text the **package** chooses goes through the catalog. Text the caller passes in stays
verbatim and is the app's job to localize.

1. **Declare it in `Sources/Components/Localization/Strings.swift`** under the component's
   namespace, as a `LocalizedStringResource` with `bundle: .atURL(Bundle.module.bundleURL)` and
   a translator `comment:` that says where it appears. Use string interpolation for dynamic
   parts (`"Error: \(message)"` becomes the key `Error: %@`). If `comment:` plus its string
   would pass 120 columns, put the string on its own line after `comment:`.
2. **Use it** as `Text(Strings.X.y)` in views, or `String(localized: Strings.X.y)` where an
   API takes a `String`. Never `Text("literal")` for package text: that looks the key up in
   the app's bundle, not the package's.
3. **Add the key to `Sources/Components/Resources/Localizable.xcstrings`** with the same
   `comment`, `"extractionState" : "manual"`, and a `translated` `stringUnit` for **every**
   locale in `REQUIRED_LOCALES` in `Scripts/check-localizations.py` (43 today, including the
   `en-*` variants). Keep keys in the file's alphabetical order. Edit the JSON with a small
   script (load, insert, validate with `json.loads`) rather than by hand.
4. **Validate** with `python3 Scripts/check-localizations.py`.
5. **Test** that the English value resolves, in
   `Tests/SwiftUIComponentsTests/Components/AccessibilityStringsTests.swift`:
   `#expect(String(localized: Strings.X.y) == "…")`.
6. List the new chrome string in the **Accessibility & Localization** bullets of
   `docs/ai-integration.md` and `README.md`.
