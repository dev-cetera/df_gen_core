# Changelog

## [0.8.2]

- Released @ 10/2026 (UTC)
- build: widen `analyzer` to `>=8.2.0 <15.0.0` (verified against 8.2.0 and 14.6.0). The floor rises from 8.0.0 because the code uses `LibraryElementResult.element` and `Element.metadata`, which first appear in 8.1.0 (marked experimental until 8.2.0), so 0.8.1 never compiled against 8.0.0. Widen `equatable` to `>=2.0.7 <4.0.0`, and bump `df_log` to `^0.6.1`. Drop the unused `source_gen` dependency (nothing imported it, and its 4.3 line pins analyzer 14 only).
- fix: annotations written with an unnamed constructor (`@GenerateDartModel(...)`, `@Field(...)`) were no longer found under analyzer 14, which reports such a constructor's display name as `GenerateDartModel.new`. `DartAnnotatedClassAnalyzer` now builds the annotation name itself (`Foo`, `Foo.named`, or the constant's name), so it is the same on every analyzer version.
- fix: `replaceData` (and so `TemplateInterpolator`) is now single-pass. Each key is matched against the original input only, so a substituted value is never substituted again: `replaceData('{a} {b}', {'{a}': '{b}', '{b}': 'X'})` gives `{b} X`, not `X X`. When two keys' matches overlap, the key listed first wins; without overlaps the result is unchanged.
- fix: `matchesAnyPathPattern` returns `false` for an empty pattern set (it returned `true`) and matches against the path with `/` separators on every platform, so `/` patterns work on Windows. The callers that treat "no patterns" as "no filter" — `FileSystemUtility.findFilePaths` / `findSourceFilePaths` / `findGeneratedFilePaths`, `Lang.deleteAllSrcFiles` / `deleteAllGenFiles` and `GetPathCombinations` — now say so explicitly and keep their behaviour.

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
