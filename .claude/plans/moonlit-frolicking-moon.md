# Plan: Production Hardening — share_localization

## Context

The project is functionally correct for the happy path but has **critical silent bugs**, missing CI/CD affordances (always exits 0), and no standard CLI UX. It cannot be reliably used in automated pipelines. This plan prepares it for production across four layers: bug fixes → CLI UX → code quality → test coverage. Each phase is independently shippable.

---

## Phase 1: Critical Bug Fixes (P0) — ship first

### 1a. Fix silent async verification (biggest risk)

**File:** `lib/code_generation/use_cases/batch_code_generation_use_case.dart` lines 82–91

`localizations.forEach((l) async { ... })` does not await the async callback — every verification exception is swallowed. Replace with:
```dart
await Future.wait(localizations.map((localization) async {
  final verificationTask = await verificationLocalization(settings, localization);
  if (verificationTask.failed) throw verificationTask.exception;
}));
```
Same pattern fix in:
- `lib/code_generation/use_cases/android/android_code_generation_use_case.dart` — per-language `forEach` for file writes
- `lib/code_generation/use_cases/flutter/flutter_code_generation_use_case_locale.dart` — same

### 1b. Implement `skipErrorTypes` filtering

**File:** `lib/localizations/use_cases/verification_localization_use_case.dart`

The `skipErrorTypes` list is stored in the constructor but **never read**. Add a filter before throwing:
```dart
final filtered = exceptions.where((e) => !skipErrorTypes.contains(e.runtimeType)).toList();
if (filtered.isNotEmpty) throw CompositeException(filtered);
```

### 1c. Fix copy-paste bug

**File:** `lib/code_generation/use_cases/android/android_code_generation_use_case.dart`

Throws `BuildLocalizationException.missingIosSettings()` — should be `missingAndroidSettings()`.

### 1d. Fix CLI entry point

**File:** `bin/share_localization.dart`
- Make `main` `async` and `await run()`
- Call `exit(1)` when the task fails

**File:** `lib/share_localization.dart`
- Move `BatchCodeGenerationUseCase.all()` factory call inside `run()` (currently module-level global state, a testing hazard)
- Return enough information from `run()` for `main` to call `exit(1)`

---

## Phase 2: CLI UX (P1)

### 2a. Stderr for errors

**File:** `lib/common/utils/printer.dart`
- `logError` must write to `stderr` unconditionally (remove `debug` gate on error output)
- Keep `debug` flag only for stack traces
- Add `Printer.err(String message)` that always writes to `stderr`

### 2b. Argument parsing

**File:** `bin/share_localization.dart`

Parse `arguments` (currently ignored). Add:

| Flag | Behaviour |
|---|---|
| `--help` / `-h` | Print usage and exit 0 |
| `--version` | Print version and exit 0 |
| `--verbose` | Enable `Printer.debug = true` |
| `--settings <path>` | Override hardcoded `'settings.json'` path |

Pass the resolved settings path into `run(settingsPath)`.

### 2c. Improve error messages

**File:** `lib/code_generation/exceptions/build_localization_exception.dart`

Current messages say _"settings are not provided or corrupted"_ with no guidance. Change to name the missing key and how to fix it, e.g.:
> `iOS settings block is missing from settings.json. Add an "ios": { "destination_folder": "..." } entry.`

### 2d. User-friendly exception wrappers

New subtypes under `lib/common/exceptions/`:
- `SettingsNotFoundException(String path)` — wraps `FileSystemException` when settings file is missing
- `InvalidJsonException(String path, String detail)` — wraps `FormatException` from JSON parsing

Catch and wrap in `JsonData.fromFile` or `SettingsLoaderUseCase.call()`.

---

## Phase 3: Code Quality (P2)

### 3a. Rename `translation` → `translations` in `LocalizationKeyDto`

**File:** `lib/localizations/dtos/localization_key_dto.dart`
- Rename field `translation` → `translations`
- Fix `toString()` label: `localizations: $translation` → `translations: $translations`
- Update all references (grep: `\.translation\b`)

### 3b. Fix `hashCode` — use `Object.hash`

**Files:** `lib/localizations/dtos/localization_dto.dart`, `lib/localizations/dtos/localization_key_dto.dart`

Replace XOR chaining (`^`) with `Object.hash(field1, field2, ...)` / `Object.hashAll(list)`.

### 3c. Fix `CompositeException` defensive copy

**File:** `lib/common/exceptions/composite_exception.dart`

`this.exceptions = List.unmodifiable(exceptions)` to prevent post-construction mutation.

### 3d. Fix `AndroidOptionsDto` / `IosOptionsDto` constructors

**File:** `lib/settings/dtos/platform_options_dto.dart`
- `AndroidOptionsDto`: `required bool? useCamelCase` → `bool useCamelCase = false`; same for `useFilePrefixForKeys`
- `IosOptionsDto`: `required String? bundleName` / `required String? classAccessLevel` → optional named with default `null`

---

## Phase 4: Test Improvements (P2–P3)

### 4a. Extract shared mock helper

**New file:** `test/helpers/mock_file_service_helper.dart`

The `when/thenAnswer` boilerplate is copy-pasted across all four generator test files. Extract into:
```dart
void setUpMockFileService(MockFileService fileService, List<InvocationCreateFile> virtualFiles) { ... }
```

### 4b. Delete unused mocks

**File:** `test/code_generation/mocks.dart`

Remove: `MockCodeGenerationUseCase`, `MockBatchCodeGenerationUseCase`, `MockFlutterCodeGenerationUseCase`, `MockBuildIosLocalizationUseCase` — defined but never imported.

### 4c. Add `skipErrorTypes` test

**File:** `test/localizations/use_cases/verification_localization_use_case_test.dart`

Assert that when `skipErrorTypes: [VerificationLocalizationExtraArgumentException]`, an extra-argument violation returns `TaskSucceeded` (not `TaskFailed`).

### 4d. Add missing-platform-settings tests

For each platform test file, add a case: pass a `SettingsDto` with that platform's block set to `null` and assert `TaskFailed` with the correct `BuildLocalizationException` variant.

### 4e. Add `int` / `double` argument type tests + golden files

Add a fixture key with `LocalizationKeyArgumentDto(type: LocalizationKeyDtoType.int)` and corresponding golden files for Android (`%d`), iOS (`%lld`), Flutter (`int`) to lock in those format strings.

### 4f. Add error-path tests for `BatchCodeGenerationUseCase`

**File:** `test/code_generation/use_cases/generation_use_case_test.dart`

Add:
- Settings file does not exist → `TaskFailed`
- One builder fails, others succeed → `CompositeException` with one entry, other files still written

---

## Verification

```bash
dart analyze                    # zero issues
dart test                       # all green

# End-to-end happy path
cd example && dart run ../bin/share_localization.dart

# CLI flags
dart run bin/share_localization.dart --help
dart run bin/share_localization.dart --version

# CI failure detection (must print "exit: 1")
dart run bin/share_localization.dart --settings missing.json; echo "exit: $?"
```

---

## Execution Order

```
Phase 1 (P0 bugs)  →  Phase 2 (CLI UX)  →  Phase 4a–4b (test cleanup)  →  Phase 3 (quality)  →  Phase 4c–4f (new tests)
```

Phase 1 should be its own PR. Phases 2–4 can be one or two follow-up PRs.
