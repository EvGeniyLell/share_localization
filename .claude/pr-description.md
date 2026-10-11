## What
Hardens code generation for all three platforms: the generated iOS, Flutter and Android files are now valid for any source text, invalid or clashing resource names fail with a clear error, and the CLI reports every problem in one run.

## Why
Before this branch the tool could write output that did not compile or silently changed the text: unescaped backslashes, `%`, `$`, `&`, quotes, line breaks and control characters; keys that gave an invalid or duplicate identifier; and only the first load/verify error was reported. All of these were found by reading the generators and confirmed with a failing test first.

## Changes

**Escaping (generated output changes)**
- Android: backslash first, `&`, `<`, `"`, `'`, `\n`, `\t`; a literal `%` becomes `%%` only for strings with arguments; a leading `@` or `?` is escaped; a carriage return is written as `\u000d` (aapt2 has no `\r` escape); values with leading, trailing or repeated spaces are wrapped in double quotes (checked with aapt2, `\u0020` does not work); `--` is broken in description comments; argument positions follow the declared arguments when placeholders are reordered.
- Flutter: backslash and literal `$` escaped; placeholders followed by an identifier character use `${name}`; snake_case arguments produce compiling code; line breaks in doc comments are written as `\n` / `\r`.
- iOS: `import Foundation` generated in Swift files; `%` and JSON special characters escaped in `.xcstrings`; control characters written as `\u00xx`; key comments escaped.

**Name validation (new errors)**
- One shared check for all platforms (`resource_name_validation.dart`): invalid identifier, empty key base, duplicate name. One error per key; several are reported as a `CompositeException`.
- New `InvalidResourceNameException` and `DuplicateResourceNameException` (field `platform`).
- iOS duplicates are decided by camelCase base plus argument types, so `var foo` and `func foo(_:)` stay allowed.
- Android names share one namespace across bundles: a cross-bundle clash is an error, the Android builder is skipped for all bundles, and the bundle's own errors are still reported in the same run.

**Error reporting and CLI**
- All load and verify errors are collected instead of stopping at the first; equal warnings are reported once; skipped verification errors become build warnings.
- Errors go to stderr. Colour is decided per stream and `NO_COLOR` disables it.
- New `--settings=<path>`; a flag given as its value is rejected.
- A missing settings file is `SettingsNotFoundException`; other read failures are `FileReadException`.
- `getFilesInDirectory` returns files sorted by path, so bundle order and error order are the same on every machine.

**Typing**
- `PlatformSettingsDto<Options extends PlatformOptionsDto>`, `TaskResult<R, E extends AppException>`, builder maps typed `Object Function(JsonData)`.

**Tests and fixtures**
- 256 tests (`dart test`), `dart analyze lib test bin` is clean. Each fix started with a failing test and was mutation-checked in a copy.
- Added `test_numbers` goldens in `example/test_results/`; regenerated 4 files in `example/results/` (`import Foundation`, Flutter escapes).
- `README.md`: new sections for the command-line options, the exit code and the output rules.
- Repository notes added: `CLAUDE.md`, `.claude/plans/moonlit-frolicking-moon.md` (backlog and decisions), `.claude/agents/code-generator.md`, `.claude/skills/pr-description/`.
- Formatting-only changes in a few files were kept in the commit that touched them (`39ec96c`).

## Breaking changes
- **Exit code.** The CLI now exits with 1 when the build has errors. Warnings (for example a missing platform section in `settings.json`, or an extra argument in a translation) are only logged and keep exit code 0. Before, it always exited normally, so a pipeline that was green can turn red.
- **Verification is enforced.** The old `load` ran verification in `forEach(async …)` without awaiting it, so missing-language and missing-argument errors were lost. They are now collected and fail the run (extra-argument errors stay warnings).
- **Unknown CLI arguments** exit with 1; before they were ignored.
- **Library API** (exported from the barrels): `LocalizationKeyDto.translation` is renamed to `translations`; `run()` returns `Future<bool>` and the top-level `builder` is removed; `BatchCodeGenerationUseCase.call` returns `Task<BuildReport>` and `load` returns a three-value record; `TaskResult` is bound to `E extends AppException`. New `CodeGenerationUseCase` methods have defaults, so existing subclasses still compile.
- Version is `0.0.6` in `pubspec.yaml`, `consts.dart` (a test checks they match) and `CHANGELOG.md`, which has the release note. `README.md` now documents the options, exit codes and `NO_COLOR`.
- **`--settings` moves only the settings file.** `sources_folder` and the destination folders are still resolved from the working directory (tracked as N22 in the plan).

## Risks and review focus
- **Generated output changes for existing users.** Strings with the characters above now differ from earlier runs. Expect a diff in committed output files.
- **Inputs that used to generate now fail:** invalid or duplicate names (any platform) and cross-bundle Android duplicates. This is intended; the message names the key and bundle.
- `example/results/` is both live output and the expected content of the batch test, so it cannot prove escaping on its own; the escape rules are covered by unit tests and `example/test_results/`.
- Not covered by design: Flutter reserved words (`class`, `default`) and `Object` member names (`hashCode`).
- History note: commit `86af022` carries the message of `62d39d3` but holds a different item, and `99506e7` describes only Android although it also covers Flutter and iOS.

## Before release
- Android `%%` and quoted values on a device or emulator (verified with aapt2 only). Owner: repo owner.
- R7 colour was checked by hand in a terminal (green, red, `NO_COLOR`, redirected stderr).
- Open ideas (Low, in the plan): N22 resolve paths from the settings file's folder; N23 friendlier message for an unknown option.
