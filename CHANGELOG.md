## 0.0.1

- Initial version.

## 0.0.2

- Introduce class access level for generated Swift classes in iOS settings.

## 0.0.3

- Add escaping rules for special characters in localization files.

## 0.0.4

- Fix CamelCase/SnakeCase and add postfix `Localization` to ios and flutter
  naming

## 0.0.5

- Add support for `useFilePrefixForKeys` for android.

## 0.0.6

- **Breaking:** the CLI exits with code 1 when the build has errors, and an
  unknown argument is rejected. Verification errors (missing language, missing
  argument) now fail the run instead of being lost.
- **Breaking:** library API: `LocalizationKeyDto.translation` is renamed to
  `translations`, `run()` returns `Future<bool>`, `BatchCodeGenerationUseCase`
  returns a `BuildReport`.
- Fix escaping in generated files: backslash, `%`, `$`, `&`, `<`, quotes, tabs,
  carriage returns, edge and repeated spaces (Android values are wrapped in
  quotes), control characters in `.xcstrings`, line breaks in doc comments.
- Generate `import Foundation` in iOS Swift files.
- Fail with a clear error on invalid, empty or duplicate resource names, also
  across Android bundles.
- Report every load and verification error in one run; errors go to stderr,
  colour is decided per stream and `NO_COLOR` is honoured.
- Add `--settings=<path>`.
- Sort bundle files by path so the output is the same on every machine.