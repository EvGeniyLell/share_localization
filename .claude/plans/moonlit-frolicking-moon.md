# Plan: Production Hardening — share_localization

## Status (branch `moonlit-frolicking-moon`, tip `47192b1`, everything committed)

| Phase | Status | Commits |
|---|---|---|
| 1 Critical bug fixes | ✅ Done | `74ba3ae` |
| 2 CLI UX | ✅ Done | `edb6e54`, `fe793ba`, `275b00a` |
| 3 Code quality | ✅ Done | `edb6e54` |
| 4 Test improvements | ✅ Done | `60810d8`, `41806a2`, `e901527`, `936e080`, `aa57390` |
| Found while testing (not in the original plan) | ✅ Done | `7da889c`, `f7ce159`, `88f4ca0`, `c49c043`, `b4c2138` |
| Requested additions | ✅ Done | `448ff77` |
| Backlog R1, R2, R4, R5, N0 | ✅ Done | `8e25f71`, `1239cea`, `40295ef`, `06338d1`, `72bcc0e` |
| Backlog R6, N8 | ✅ Done | `9e8f0cb` |
| Backlog N5, N9 | ✅ Done | `40c258c` |
| Backlog N1 | ✅ Done | `6cc70b7` |
| Backlog R3 | ✅ Done | `a231c21` |
| Backlog R8 | ✅ Done | `62d39d3` (`86af022` has the same message but holds N2) |
| Backlog N2 | ✅ Done | `86af022` |
| Backlog N3 | ✅ Done | `fbb1314` |
| Backlog N12, N14, N15 (shared name validator, one commit) | ✅ Done | `99506e7` (the message only mentions Android) |
| Backlog N4 | ✅ Done | `a5e46a2` |
| Backlog N7 | ✅ Done | `4d0968c` |
| Backlog N11 | ✅ Done | `7e1ae7b` |
| Backlog R9, R10, R7 | ✅ Done | `47f7fae`, `8ba8121`, `aa3e842` |
| Backlog N13 | ✅ Done | `da987f1` |
| Backlog R11, N18 | ✅ Done | `f146952`, `47192b1` |
| Backlog N6, N10 | ↪ Closed, not a bug | checked by running / by `swiftc` |
| N16 | ✅ Done | `getFilesInDirectory` sorted by path (committed by the owner) |
| N19 | ✅ Done | builder maps typed `Object Function(JsonData)` (committed by the owner) |
| N17 | ✅ Done, uncommitted (249/249, analyze clean) | skipped builder still runs `validateBundle` |

**Verification now:** `dart test` 246/246 green. `dart analyze lib test bin` reports no issues.
Not yet verified on a real device or terminal: the Android `%%` rule (see B2), `\u0020` for edge
spaces (N4), and R7 colour in a real TTY (`2> file`, `| tee`, `NO_COLOR=1`).

Legend: ✅ done · ⏳ open · ↪ deviates from the plan (reason given).

---

## Resume here (handoff for a new session)

**Start:** open the session in `/Users/evg/Work/share_localization` (the main folder, branch
`moonlit-frolicking-moon`), with automatic worktrees switched off. Read this file and `CLAUDE.md`
first. All code fixes above are committed; the only uncommitted change may be this plan file.

**Next task:** none required. The hardening backlog is empty: N16, N17 and N19 are done. Before a release, by hand: the Android `%%` and `\u0020`
rules on a device, and the R7 colour in a real terminal. Housekeeping: remove the old worktree and
branch `claude/cli-stderr-errors-d3067c`.

**What the backlog changed (so you do not redo it):** every escape function keeps the backslash
step FIRST. Name validation is shared: `resource_name_validation.dart` (`validateResourceNames`,
`ResourceNameEntry` with `identity`) used by Android, Flutter and iOS before any file is written;
errors are `InvalidResourceNameException` and `DuplicateResourceNameException` (field `platform`,
`otherBundleName` for clashes across bundles, found by the hook
`CodeGenerationUseCase.validateBundles`). Load and verify errors of all bundles are reported
together. Colour is decided per stream and `NO_COLOR` is honoured.

**Commits:** the owner commits by hand. Do not run `git commit` / `git add` / `git reset` unless
asked; leave fixes and tests in the working tree and list the changed files.

**How we work (keep doing this):**
1. One item at a time, WIP 1. Finish and commit before starting the next.
2. TDD: write the test first and see it **red** with the wrong actual value, then fix, then green.
3. Check the test really guards the fix: copy the project to the scratchpad, break the code there
   (mutation), confirm the test fails. Never mutate the real tree.
4. One commit per fix, message explains *why*. Run `dart analyze` (touched files) and `dart test`.
5. Do not regenerate `example/results/` with the tool: it adds whitespace-only noise. Edit the
   few expected lines by hand. `tremContent()` ignores per-line whitespace in the tests.

**Repo facts that are easy to miss:**
- `example/results/` is the live output **and** the expected content of the batch test. It is
  committed, so it is circular: a wrong generator plus regenerated results still passes. Use
  independent expectations (`example/test_results/` goldens written by hand, or inline strings).
- Keep argument names in new fixtures as single words unless the test is about names (B1 is fixed,
  but single words keep goldens small).
- `dart analyze` on the whole repo shows ~95 errors, almost all in `example/results/flutter/`
  because Flutter is not installed. Only `Undefined name` for **our own argument names** is a real
  generator bug. `dart analyze lib test bin` is clean.
- `SettingsDto.copyWith` cannot reset a field to null; build the DTO directly (see
  `settingsDtoWithoutIos` in `test/settings/mocks.dart`).

**Decisions already taken (do not reopen):**
- `logError` is debug-only; the user-facing error is printed once by `run()`.
- Android: `%` → `%%` only for keys **with** arguments; keys without arguments stay as they are.
- Flutter: `$` → `\$`; `{size}MB` → `${size}MB`; placeholder names go through `camelCase()`.
- A failing builder does not fail the task; it is listed in `BuildReport.errors`.
- Hand-written parser in `bin/`, no `args` dependency. `--settings <path>` refuses a value that starts
  with `-`; `--settings=<path>` is supported (an empty value is an error).
- Resource names are validated (error, exit 1, no file written) instead of being silently
  sanitised; invalid, empty-base and duplicate names are errors on every platform.
- iOS duplicate identity = camelCase base + argument types (`iosXCStringKey()`), because Swift
  allows `var foo` next to `func foo(_:)` (checked with `swiftc`).
- A builder with a cross-bundle clash is skipped for all bundles; the other builders still run.
- Colour per stream (stdout for warnings/success, stderr for errors); a non-empty `NO_COLOR` wins.

**Not verified yet:** the Android `%%` rule was not run on a device. Check once in Android Studio.

**Environment notes (from this session):**
- A session started in a git worktree cannot edit the main folder and cannot move into it. Work
  in the main folder directly, or merge with `git merge --ff-only <worktree-branch>`.
- A GateGuard hook asks for "facts" before the first edit of each file and before `rm -rf`
  commands. It is a local ECC hook; it can be relaxed with `ECC_DISABLED_HOOKS`, that is the
  owner's call.

**Housekeeping (owner: repo owner):**
- Remove the old worktree and branch:
  `git worktree remove .claude/worktrees/cli-stderr-errors-d3067c && git branch -d claude/cli-stderr-errors-d3067c`
- Before release: run the Android `%%` check.

---

## Context

The project is functionally correct for the happy path but has **critical silent bugs**, missing CI/CD affordances (always exits 0), and no standard CLI UX. It cannot be reliably used in automated pipelines. This plan prepares it for production across four layers: bug fixes → CLI UX → code quality → test coverage. Each phase is independently shippable.

---

## Phase 1: Critical Bug Fixes (P0) — ✅ `74ba3ae`

### 1a. Fix silent async verification — ✅
`BatchCodeGenerationUseCase.load`, the Android generator and the Flutter locale generator now
use `await Future.wait(... .map(...))` instead of `forEach(async ...)`.

### 1b. Implement `skipErrorTypes` filtering — ✅
Filter applied in `VerificationLocalizationUseCase.call` for both the language and the key checks.
Tested in 4c. ⏳ See R1: skipped errors are currently dropped without a warning.

### 1c. Fix copy-paste bug — ✅
Android now throws `missingAndroidSettings()`. Locked by a test in 4d.

### 1d. Fix CLI entry point — ✅
`main` is async and calls `exit(1)` on failure. `run({settingsPath})` builds the use case inside
the function and returns `bool`. ↪ It returns `!report.hasErrors`, because `BatchCodeGenerationUseCase`
now returns a `BuildReport` (errors vs warnings) instead of throwing a `CompositeException`.

---

## Phase 2: CLI UX (P1) — ✅

### 2a. Stderr for errors — ✅ `fe793ba`, `275b00a`
`Printer.errorOutput` and `Printer.err()` added. ↪ `logError` prints details (error and stack
trace) to stderr in debug mode only. The user-facing message is printed once by `run()` through
`BuildReportPrinter`; the plan said "unconditionally", which printed the same error 3 times for a
missing settings file (nested `runAppTaskSafely`). Tests: `printer_test.dart`, `cli_test.dart`.

### 2b. Argument parsing — ✅ `edb6e54` (tests `275b00a`)
`--help/-h`, `--version`, `--verbose`, `--settings <path>`. ↪ Hand-written parser, no `args`
dependency. Usage errors exit 1. ⏳ See R10: `--settings` takes the next token even if it is a flag.

### 2c. Improve error messages — ✅ `edb6e54`
`BuildLocalizationException` messages now name the missing block.

### 2d. User-friendly exception wrappers — ✅ `edb6e54`
`SettingsNotFoundException`, `InvalidJsonException`, wrapped in `JsonData.fromFile`.
✅ See R3 (`a231c21`): wrong message for bundle files and non-"not found" I/O errors.

---

## Phase 3: Code Quality (P2) — ✅ `edb6e54`

- 3a ✅ `translation` → `translations` (field, `copyWith`, `toString`, all references).
- 3b ✅ `hashCode` uses `Object.hash` / `Object.hashAll`.
- 3c ✅ `CompositeException` copies with `List.unmodifiable`.
- 3d ✅ ↪ `IosOptionsDto` fields are optional. `AndroidOptionsDto` keeps `bool?` parameters with
  `?? false`: the settings loader passes a nullable `data.get(...)`, so `bool x = false` would not compile.

---

## Phase 4: Test Improvements (P2–P3) — ✅

- 4a ✅ `60810d8` `test/helpers/mock_file_service_helper.dart` (`setUpMockFileService`).
- 4b ✅ `60810d8` The four unused mocks removed. ↪ The whole `test/code_generation/mocks.dart` was
  deleted, nothing imported it once they were gone.
- 4c ✅ `41806a2` `skipErrorTypes` tests: skip succeeds, no skip fails, skipping one type does not
  hide another. Mutation-checked.
- 4d ✅ `e901527` Missing-platform-settings tests for iOS, Android, Flutter (`settingsDtoWithout*`
  in `test/settings/mocks.dart`, because `copyWith` cannot reset a field to null).
- 4e ✅ `936e080` New key `file_report` with String, Double and Int arguments and hand-written golden
  files for the three platforms (`example/test_results/*test_numbers*`). ↪ Argument names are single
  words on purpose (see B1); the placeholders are reordered so the Android golden also covers `7da889c`.
- 4f ✅ `aa57390` Batch error paths. ↪ A failing builder does not fail the task: it is reported in
  `BuildReport.errors` and the other builders still write files (there is no `CompositeException`).

---

## Found while testing (not in the original plan) — ✅

| ID | Fix | Commit |
|---|---|---|
| A1 | Android used the order of placeholders in the text, not the declared argument, for position and type (`{size} for {file}` gave `%1$s for %2$f`). Now looked up by name. | `7da889c` |
| B1 | Flutter body used `$file_name` while the parameter is `fileName`: the generated code did not compile. Also fixed the two committed results. | `f7ce159` |
| B3 | `{size}MB` was emitted as `$sizeMB`. Now `${size}MB` when an identifier character follows. | `88f4ca0` |
| B2 | Android: literal `%` becomes `%%` **only for keys with arguments**. | `c49c043` |
| B4 | Flutter: literal `$` becomes `\$`. | `b4c2138` |

B2 caveat: the rule follows the Android docs and community sources, but it was **not run on a
device**. Check once in Android Studio before release.

---

## Requested additions — ✅

| ID | Change | Commit |
|---|---|---|
| I1 | iOS: every generated Swift file starts with `import Foundation`. Expected files updated: `example/results/ios/*.swift` and `example/test_results/ios/*.swift`. Four iOS tests were red first, then green. | `448ff77` |

---

## Open backlog (from the code review of `main..moonlit-frolicking-moon`)

Ordered by impact. R1–R3 were reproduced by running the tool; the rest come from reading the code.

| ID | Where | Problem | Class of service |
|---|---|---|---|
| R1 ✅ `8e25f71` | `verification_localization_use_case.dart:16` | Errors in `skipErrorTypes` vanish. CLAUDE.md says they become a warning. Reproduced: unused argument → "Build completed successfully", no warning. | Standard |
| R2 ✅ `1239cea` | `batch_code_generation_use_case.dart:47` | `Set` replaced by `List`: the same warning repeats once per bundle (reproduced: 2 bundles, 2 identical warnings). | Standard |
| R3 ✅ `a231c21` | `json_data.dart:30` | Any `FileSystemException` is reported as `SettingsNotFoundException`, also for bundles (reproduced with an unreadable bundle). Invalid UTF-8 gave the same wrong message (not `UnexpectedException`). Fix: missing file → `SettingsNotFoundException`, other read errors → new `FileReadException`. | Standard |
| R4 (B5) ✅ `40295ef` | `android_code_generation_use_case.dart:60` | `&` (and a leading `@` / `?`) not escaped: invalid Android XML. | Standard |
| R5 (B6) ✅ `06338d1` | `flutter_code_generation_use_case.dart:72` | Backslash not escaped in the Dart string. | Standard |
| R6 (B7) ✅ `9e8f0cb` | `ios_code_generation_use_case.dart:85` | Literal `%` not escaped in xcstrings values of keys with arguments (same defect as B2). | Standard |
| R7 ✅ `aa3e842` | `build_report_printer.dart:12` | ANSI decided by `stdout` but written to `stderr`; `NO_COLOR` ignored. Fixed: colour decided per stream (log lines by stdout, error lines by stderr), non-empty `NO_COLOR` disables it; constructor seam `stdoutAnsi`/`stderrAnsi`/`environment`; 13 new tests. NOT run in a real TTY (no pty in the agent sandbox). | Low |
| R8 ✅ `62d39d3` | `batch_code_generation_use_case.dart:78` | `Future.wait` keeps only the first load/verify error across bundles. Fixed: all collected, flattened `CompositeException` in file order. | Low |
| R9 ✅ `47f7fae` | `build_report_printer.dart:4` | 3 lines over 80 chars: fixed with a `_count` helper, output pinned by 8 new characterisation tests. The "deep import" no longer exists (sibling files of the same module are imported directly, like in the other generators). | Low |
| R10 ✅ `8ba8121` | `bin/share_localization.dart:23` | `--settings --verbose` took `--verbose` as the path; `--settings=path` was rejected; no CLI test for `InvalidJsonException`. Fixed: a `-`-prefixed next argument is "requires a path"; `--settings=<path>` supported (empty value is an error, `--settings=-x` keeps the value); 7 new real-process tests incl. `InvalidJsonException`. | Low |
| R11 ✅ `f146952` | `platform_settings_dto.dart:11` | The type parameter `PlatformOptionsDto` shadowed the class of the same name (the last analyze info). Fixed: `Options extends PlatformOptionsDto`, so only the three platform option classes can be used (proved in a scratch copy: `PlatformSettingsDto<String>` fails with `type_argument_not_matching_bounds`). | Low |

Found while doing R4 (from reading the code and the agent's report, not reproduced by running
the tool):

| ID | Where | Problem | Class of service |
|---|---|---|---|
| N0 ✅ `72bcc0e` | `android_code_generation_use_case.dart` `androidTranslationEscape` | A literal `\` is passed through; aapt reads it as an escape sequence (`C:\dir`, `\d`) and the build can fail. Same family as R5, other rules. | Standard |
| N1 ✅ `6cc70b7` | `android_code_generation_use_case_xml.dart` | The description goes into `<!-- $description -->`; `--` or `-->` in it breaks the XML. | Standard |
| N2 ✅ `86af022` (committed under the R8 message) | same | `"` was not escaped (aapt drops it). Fixed: `"` → `\"` after the backslash step. | Low |
| N3 ✅ `fbb1314` | same | A key that gives an invalid resource name (starts with a digit, characters outside `[a-z0-9_]`) was not validated. Fixed: error `InvalidResourceNameException` (regex `^[A-Za-z_][A-Za-z0-9_]*$` on the final name), all bad keys of a bundle reported together. Open caveat: with `use_file_prefix_for_keys` a key with no ASCII letters collapses to the bare prefix (valid but wrong, duplicates possible). | Low |
| N4 ✅ `a5e46a2` | same | Leading, trailing and repeated spaces, and a literal tab, are collapsed by Android into one space: valid output, different from the source (`Name:<tab>Value` shows as `Name: Value`; iOS and Flutter keep the tab). Fixed: tab → `\t`; leading, trailing and repeated spaces → `\u0020` (regex `^ | $|(?<= ) `). Not run on a device: confirm aapt accepts `\u0020` in the real build. | Low |

Found while doing R5 (from the agent's report, not yet reproduced by running the tool):

| ID | Where | Problem | Class of service |
|---|---|---|---|
| N5 ✅ `40c258c` | `flutter_code_generation_use_case.dart` `flutterEscape` | A real `\r` is not escaped: a raw carriage return lands inside a single-quoted Dart string. Probably the same on Android and iOS (check). | Standard |
| N6 ✅ not a bug | same | A placeholder `{unknown}` that is not a declared argument: reproduced with the tool, verification stops the build first (`Missing argument "unknown"`, exit 1, no files written; covered by `failed with missingArgument` in `verification_localization_use_case_test.dart`). Nothing to fix. | closed |
| N7 ✅ `4d0968c` | `flutterDocCommentEscape` (was `flutterDescriptionEscape`) | Text in a `///` comment: `\r` in the description ended the line and the rest became Dart code, and `key.comment` was not escaped at all (`\n` or `\r` there also injected code). Fixed: one escape (`\n`, `\r` as two characters) for both comment and description. | Low |

Found while doing R6 (confirmed by reading the code, not run):

| ID | Where | Problem | Class of service |
|---|---|---|---|
| N8 ✅ `9e8f0cb` | `ios_code_generation_use_case.dart` `iosXCSTranslationEscape` | The xcstrings value is JSON: a literal `\` is not escaped (`C:\dir` is an invalid JSON escape, backslash+n becomes a newline); raw tab and `\r` are invalid JSON too (tab and `\r` inferred from the JSON spec). Same rule as N0 and R5: backslash step first. | Standard |
| N9 ✅ `40c258c` | `ios_code_generation_use_case_xcstrings.dart:29`, `..._swift.dart:66` | `key.comment` is inserted unescaped into the xcstrings JSON (a `"`, backslash or newline breaks the JSON) and into the Swift `///` comment (a newline ends the block, the rest becomes Swift code). | Standard |
| N10 ↪ closed, not a bug | `iosSwiftTranslationEscape` | Backslash in a Swift `///` comment. Checked with swiftc: `\`, `\"`, `\(x)`, `\u{ZZ}`, `*/` and a trailing `\` all typecheck, comments do not process escapes. Only cosmetic: `"` is shown as `\"` in the doc (left as is, see N9). | Low |

Found while doing N8 (observation, not run):

| ID | Where | Problem | Class of service |
|---|---|---|---|
| N11 ✅ `7e1ae7b` | `iosXCSTranslationEscape` | Control characters U+0000–U+001F other than tab, newline and `\r` (`\b`, `\f`, NUL) are still written raw, which is invalid JSON. Fixed: remaining U+0000–U+001F → `\u00xx` (lowercase hex) after the other steps; DEL stays raw (valid JSON). The raw file used to be invalid JSON while the build reported success. | Low |
| N12 ✅ `99506e7` | `android_code_generation_use_case.dart` `_validateResourceNames` | Android names are not checked for an empty key base (with `use_file_prefix_for_keys` a key without ASCII letters collapses to the bare prefix) or for duplicates inside a bundle (`my-key` and `my_key` both give `my_key`, also without a prefix). Fixed: `InvalidResourceNameReason.emptyKeyBase` and new `DuplicateResourceNameException` (`platform` field, names both keys); one error per key, all reported together. | Standard |
| N13 ✅ `da987f1` | `batch_code_generation_use_case.dart` | Duplicate Android names ACROSS bundles (same key in two bundles, prefix off) are not checked; Android merges all `values/*.xml`. Fixed: hook `CodeGenerationUseCase.validateBundles`, Android override (bundles sorted by name, clash only against a different bundle); a builder with a clash is skipped for ALL bundles while the others still run; `DuplicateResourceNameException.otherBundleName`. 7 new tests. | Low |
| N14 ✅ `99506e7` | `flutter_code_generation_use_case.dart` | Flutter: duplicate or empty/invalid `camelCase()` names (`my-key` + `my_key`, `ключ`) were written as duplicate getters and `String get ;`. Fixed with the shared validator; reserved words (`class`) and `Object` member clashes (`hashCode`) are NOT checked. | Standard |
| N15 ✅ `99506e7` | `ios_code_generation_use_case.dart` | iOS: same defect in Swift (`static var myKey` twice, `static var :`) and xcstrings (duplicate `"myKey"`, `""`). Fixed with the shared validator. Duplicate identity on iOS = `iosXCStringKey()` (camelCase base + argument types): `var foo`, `func foo(String)` and `func foo(Int)` are allowed (checked with swiftc), same base and same types is an error. `ResourceNameEntry.identity` carries it. | Standard |
| N16 | `lib/common/services/file_service.dart:18` | `getFilesInDirectory` returns files in `listSync()` order, which depends on the file system. Bundle order is therefore not deterministic across machines: the order of errors and warnings (R8), the "first holder" in duplicate reports (N12) and the order of generated output can differ. Fix idea: sort the files by path. N13 sorts bundles by name inside its own check as a stop-gap. **Done (uncommitted):** the method returns `List<File>` sorted by path; test `test/common/services/file_service_test.dart` failed first with `[mid, beta, gamma, zeta, alpha]`; mutation (sort removed) fails it again. The N13 sort stays as defence in depth. | Low |
| N17 | `batch_code_generation_use_case.dart` (N13 skip) | When Android is skipped because of a cross-bundle clash, its per-bundle checks (N3, N12) do not run, so a same-bundle duplicate or invalid name in the same run is reported only after the clash is fixed (errors arrive in two rounds). Fix idea: run the per-bundle validation for a skipped builder too, without writing files. **Done (uncommitted):** new hook `CodeGenerationUseCase.validateBundle` (null by default, Android overrides it); `build()` calls it for a skipped builder, so the cross-bundle clash and the bundle's own errors arrive in one run. Test `skipped Android builder still reports per-bundle errors` failed first with actual `{Duplicate}`; mutation (hook call removed) fails it again. | Low |
| N18 ✅ `47192b1` | `lib/common/utils/task_result.dart` | `TaskResult<R, E>`, `TaskSucceeded` and `TaskFailed` have an unbounded `E`, although it is always `AppException` (fixed by the typedefs in `task.dart`; the raw classes are not exported). Fixed: `E extends AppException` on all three (proved in a scratch copy: `TaskResult<int, String>` fails with `type_argument_not_matching_bounds`). | Low |
| N19 | `settings_loader_use_case.dart:31`, `localization_loader_use_case.dart:23` | The builder maps are `Map<Type, Function>`: the raw `Function` type means the compiler does not check the builder signatures. **Done (uncommitted):** both maps are `Map<Type, Object Function(JsonData)>`. Proof in a scratch copy: an entry with the wrong signature gave no type error before, and `map_value_type_not_assignable` after. No runtime test is possible, the check is compile-time. | Low |

**Suggested order (updated):** backlog empty; the by-hand checks from "Status" come first before a release.

---

## Verification

```bash
dart analyze lib test bin       # no issues
dart test                       # 246 green

# End-to-end happy path
cd example && dart run ../bin/share_localization.dart

# CLI flags
dart run bin/share_localization.dart --help
dart run bin/share_localization.dart --version

# CI failure detection (must print "exit: 1")
dart run bin/share_localization.dart --settings missing.json; echo "exit: $?"
```

---

## Execution Order (original)

```
Phase 1 (P0 bugs)  →  Phase 2 (CLI UX)  →  Phase 4a–4b (test cleanup)  →  Phase 3 (quality)  →  Phase 4c–4f (new tests)
```

Phase 1 should be its own PR. Phases 2–4 can be one or two follow-up PRs.
