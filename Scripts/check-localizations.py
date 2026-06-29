#!/usr/bin/env python3

import json
import sys
from pathlib import Path


CATALOG_PATH = Path("Sources/Components/Resources/Localizable.xcstrings")
REQUIRED_LOCALES = [
    "en",
    "en-AU",
    "en-CA",
    "en-GB",
    "ar",
    "bg",
    "ca",
    "cs",
    "da",
    "de",
    "el",
    "es",
    "es-419",
    "es-MX",
    "fi",
    "fr",
    "fr-CA",
    "fa",
    "he",
    "hi",
    "hr",
    "hu",
    "id",
    "it",
    "ja",
    "ko",
    "ms",
    "nb",
    "nl",
    "pl",
    "pt-BR",
    "pt-PT",
    "ro",
    "ru",
    "sk",
    "sl",
    "sv",
    "th",
    "tr",
    "uk",
    "vi",
    "zh-Hans",
    "zh-Hant",
]


def validate_catalog(path):
    if not path.exists():
        return [f"missing string catalog: {path}"]

    data = json.loads(path.read_text(encoding="utf-8"))
    failures = []

    if data.get("sourceLanguage") != "en":
        failures.append("sourceLanguage must remain 'en'")

    for key, entry in data.get("strings", {}).items():
        localizations = entry.get("localizations", {})
        if not localizations:
            continue

        for locale in REQUIRED_LOCALES:
            localization = localizations.get(locale)
            if localization is None:
                failures.append(f"{key!r} is missing locale {locale}")
                continue

            string_unit = localization.get("stringUnit")
            if string_unit is None:
                failures.append(f"{key!r} locale {locale} is missing stringUnit")
                continue

            state = string_unit.get("state")
            value = string_unit.get("value")
            if state != "translated":
                failures.append(f"{key!r} locale {locale} has state {state!r}, expected 'translated'")
            if value is None or value == "":
                failures.append(f"{key!r} locale {locale} is missing a value")

    return failures


def main():
    failures = validate_catalog(CATALOG_PATH)
    if failures:
        print("Localization validation failed:", file=sys.stderr)
        visible_failures = failures[:100]
        for failure in visible_failures:
            print(f"- {failure}", file=sys.stderr)
        if len(failures) > len(visible_failures):
            remaining = len(failures) - len(visible_failures)
            print(f"- ... and {remaining} more localization issue(s)", file=sys.stderr)
        return 1

    print("Localization validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
