# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`share_localization` is a Dart command-line tool (not Flutter) that reads source
localization bundles and a `settings.json`, then generates platform-native
localization files for iOS (`.swift` + `.xcstrings`), Flutter (`.dart`), and
Android (`.xml`). Its job is to keep localization strings consistent across
languages and platforms from a single source of truth.

## Commands

```bash
dart pub get                 # install dependencies
dart analyze                 # static analysis / lint (see analysis_options.yaml)
dart test                    # run all tests
dart test test/code_generation/use_cases/ios_code_generation_use_case_test.dart   # single test file
dart test --name "substring" # run tests matching a name
dart run bin/share_localization.dart   # run locally (expects settings.json in CWD)

# Run against the bundled example (from repo root):
cd example && dart run ../bin/share_localization.dart

# Install globally for end-to-end testing:
dart pub global activate --source git git@github.com:EvGeniyLell/share_localization.git
```

The executable expects a `settings.json` in the **current working directory**
and resolves all paths relative to it. The `example/` directory contains a
complete working sample (`settings.json`, `bundles/`, `results/`).

## Architecture

The pipeline is a single orchestrator that runs in three phases. Entry point
`bin/share_localization.dart` → `lib/share_localization.dart` `run()` →
`BatchCodeGenerationUseCase.all()` (`lib/code_generation/use_cases/batch_code_generation_use_case.dart`),
which is the central coordinator:

1. **Load** — `SettingsLoaderUseCase` parses `settings.json`; then every `.json`
   file in `sources_folder` is parsed by `LocalizationLoaderUseCase` into
   `LocalizationDto`s.
2. **Verify** — `VerificationLocalizationUseCase` checks the loaded localizations
   against the settings (e.g. missing languages, argument mismatches). By default
   `BatchCodeGenerationUseCase.all()` skips `VerificationLocalizationExtraArgumentException`,
   downgrading it to a warning rather than a hard failure.
3. **Build** — each registered `CodeGenerationUseCase` (Flutter, iOS, Android)
   is invoked per localization and writes files via `FileService`.

Code is organized into four feature modules under `lib/`, each with a barrel
file (`<module>.dart`) that re-exports its public API. Import the barrel, not
individual files:

- `common/` — cross-cutting utilities: the `Task` result type, exceptions,
  `FileService`, string/JSON helpers.
- `settings/` — `settings.json` parsing into `SettingsDto` + platform option DTOs.
- `localizations/` — source bundle parsing, DTOs, and verification.
- `code_generation/` — the orchestrator and the three platform generators.

### Key conventions

- **Error handling uses a `Task`/`TaskResult` monad, not thrown exceptions at
  boundaries.** Wrap fallible work in `runAppTaskSafely(() async { ... })`
  (`lib/common/utils/task.dart`). It catches everything, logs via `Printer`, and
  returns `TaskSucceeded`/`TaskFailed<AppException>`. *Inside* a task block you
  throw `AppException` subtypes freely; the wrapper converts them. Non-`AppException`
  errors become `UnexpectedException`. Check `task.failed` / `task.data` /
  `task.exception` at call sites. All app errors implement `AppException`;
  multiple errors are aggregated into a `CompositeException`.

- **Platform generators** extend the abstract `CodeGenerationUseCase` and are
  split across `part` files (e.g. `ios_code_generation_use_case.dart` +
  `..._swift.dart` + `..._xcstrings.dart`). To add or change generated output,
  edit the relevant `part`. To add a new platform, create a use case under
  `code_generation/use_cases/<platform>/`, add its option DTO in `settings/`,
  and register it in `BatchCodeGenerationUseCase.all()`.

- **DTO parsing** goes through `JsonData` (`lib/common/utils/json_data.dart`)
  with typed accessors (`get`, `getSub`, `getSubList`, `dtoOrNull`). Settings
  DTOs are built by a `Type → builder` map in
  `SettingsLoaderUseCase.buildDto` — register new DTO types there.

- **String case transforms** (`camelCase`, `capitalize`, `baseFilename`, etc.)
  live in `common/utils/string_case_transform_extension.dart` and
  `string_file_extension.dart`, and drive generated key/file naming. Android
  behaviour is gated by `use_camel_case` and `use_file_prefix_for_keys` settings.

### Testing

Tests mirror `lib/` under `test/`. They use `mocktail` and inject a
`MockFileService` so generators write to an in-memory list of `createFile`
invocations rather than disk.

**Golden files:** `example/test_results/` contains the expected generated content
that tests assert against. `example/results/` is the live output actually written
when you run the tool — do not confuse the two when adding new test assertions.

`Printer.debug = true` (commented at the top of test files) enables verbose
logging when debugging. Methods needed only by tests are exposed with
`@visibleForTesting`.

## Cost policy
After a plan is approved, delegate implementation to the `code-generator` subagent.
Keep the main model for architecture, review and debugging only.
