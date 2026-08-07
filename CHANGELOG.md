# Changelog

## [0.8.1]

- chore: bump `df_string` to `^0.4.0`. Adopts df_string 0.4.0's case-conversion digit-boundary change — digits now stay attached to the adjacent letter run (`phone_e164` instead of `phone_e_164`, `line1` instead of `line_1`). Code generated via case conversions on identifiers that embed digits will emit the new form on the next generation run; already-generated code is unaffected until regenerated. All 171 tests pass against df_string 0.4.0.

## [0.8.0]

- Released @ 5/2026 (UTC)
- Fix: mapper builders no longer leave stray `#x0`/`#p0` placeholders in generated code when a type lacks a matching mapper; emit a visible `MISSING_MAPPER_FOR(...)` sentinel and log the offending type
- Fix: `buildCollectionMapper` no longer crashes with `RangeError` on empty object-type strings
- Fix: `_buildMapper` coerces optional non-matching regex groups to empty string instead of force-unwrapping null
- New regression tests for the above

## [0.7.3]

- Released @ 5/2026 (UTC)
- AI fixes

## [0.7.2]

- Released @ 5/2026 (UTC)
- Bump version
- fix issues

## [0.7.1]

- Released @ 2/2026 (UTC)
- Update dependencies
- Update and format

## [0.7.0]

- Released @ 6/2025 (UTC)
- Update dependencies

## [0.6.16]

- Released @ 6/2025 (UTC)
- Update dependencies

## [0.6.15]

- Released @ 6/2025 (UTC)
- Update dependencies

## [0.6.14]

- Released @ 6/2025 (UTC)
- Update dependencies

## [0.6.13]

- Released @ 6/2025 (UTC)
- Critical bugfix

## [0.6.12]

- Released @ 6/2025 (UTC)
- Update dependencies

## [0.6.10]

- Released @ 6/2025 (UTC)
- +chore: Update dependencies
- update

## [0.6.9]

- Released @ 6/2025 (UTC)
- +chore: Update dependencies
- update

## [0.6.8]

- Released @ 6/2025 (UTC)
- +chore: Update dependencies

## [0.6.7]

- Released @ 6/2025 (UTC)
- +chore: Update dependencies

## [0.6.6]

- Released @ 6/2025 (UTC)
- +chore: Update dependencies
- update

## [0.6.5]

- Released @ 6/2025 (UTC)
- +chore: Bugfix with paths

## [0.6.4]

- Released @ 6/2025 (UTC)
- +chore: Update dependencies

## [0.6.3]

- Released @ 6/2025 (UTC)
- +chore: Update dependencies
- update

## [0.6.2]

- Released @ 6/2025 (UTC)
- +chore: Upgrade dependencies

## [0.6.1]

- Released @ 6/2025 (UTC)
- +chore: Update dependencies

## [0.6.0]

- Released @ 6/2025 (UTC)
- update

## [0.5.12]

- Released @ 6/2025 (UTC)
- +chore: Update dependencies

## [0.5.11]

- Released @ 6/2025 (UTC)
- chore: Update dependencies
