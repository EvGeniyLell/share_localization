## Share Localization

`share_localization` is a command-line tool that shares localization files for iOS, Flutter, and Android projects. 
It ensures that localization strings are consistent across different languages and platforms.

for each platform, it generates files with localizations in the format of the platform.

- ios: `swift` and `xcstrings` files
- flutter: `dart` common and locale files
- android: `xml` locale files

### Attention:
- This tool is still in development and may not work as expected.
- Feel free to share your ideas and suggestions for improving this project!

## Installation

### Global Installation

To install the tool globally:

```bash
dart pub global activate --source git git@github.com:EvGeniyLell/share_localization.git
```

To install from a specific branch:

```bash
dart pub global activate --source git git@github.com:EvGeniyLell/share_localization.git --git-ref BranchName
```

## Usage

### Command-line options

```bash
share_localization [options]
```

| Option | Meaning |
|---|---|
| `-h`, `--help` | Show the help and exit. |
| `--version` | Show the tool version and exit. |
| `--verbose` | Show stack traces with errors. |
| `--settings <path>` or `--settings=<path>` | Path to the settings file (default `settings.json`). Use the `=` form for a path that starts with `-`. |

An unknown option is an error and the tool exits with code 1.

Paths inside the settings file (`sources_folder`, `destination_folder`) are
resolved from the working directory, not from the folder of the settings file.

### Exit code and output

- The tool exits with code `1` if the build has errors, otherwise with `0`.
- Warnings are printed but do not change the exit code, for example a platform
  section missing from the settings, or an argument in a translation that the
  key does not declare.
- Messages are written to the error stream (stderr). Colour is used only when
  the stream is a terminal; set a non-empty `NO_COLOR` variable to turn it off.
- All load and verification errors are reported in one run, not only the first.

### Settings Options

The command-line tool expects to find the `settings.json` file in the working directory
(or the file given with `--settings`).

The settings file should be formatted as follows:

```yaml
languages:
  description: >-
    Language codes you want to share.
    The first language will be used for descriptions.
  type: List
  item:
    type: String
sources_folder:
  description: Folder with localization files.
  type: String (required)
  
# Next, you can see custom options for each supported platform.
# If you don't need to share localizations to some platform,
# just remove it from the settings.

ios:
  description: iOS specific options.
  type: Object? (optional)
  object:
    bundle_name:
      description: >-
        Optional name of localizations bundles.
        Use it if you have the localizations not in the main bundle.
      type: String? (optional)
      default: null
    class_access_level:
      description: >-
        Access level for generated Swift classes. 
        Can be open/public/internal/fileprivate/private or null.
      type: String (optional)
      default: null
    destination_folder:
      description: >-
        Generated files will be put here.
        Supports path back step with `../../`.
      type: String (required)
      
flutter:
  description: Flutter specific options.
  type: Object? (optional)
  object:
    destination_folder:
      description: >-
        Generated files will be put here.
        Supports path back step with `../../`.
      type: String (required)
      
android:
  description: Android specific options.
  type: Object? (optional)
  object:
    use_camel_case:
      description: >-
        Optional flag to use camelCase for keys.
      type: Boolean? (optional)
      default: false
    use_file_prefix_for_keys:
      description: >-
        Optional flag to add file name as prefix to keys.
      type: Boolean? (optional)
      default: false
    destination_folder:
      description: >-
        Generated files will be put here.
        Supports path back step with `../../`.
      type: String (required)
```

[Example settings](example/settings.json)

### Source Bundles

You should put your localization files in the folder with the name specified in the settings.

#### Format of Source Localization Files

```yaml
languages:
  description: >-
    Language codes supported in the bundle.
  type: List
  item:
    type: String
keys:
  description: Localization keys.
  type: Map
  key:
    description: Unique key of localization.
    type: String
  value:
    object:
      comment:
        description: Comment for localization.
        type: String
      arguments:
        description: Optional list of argument types and names.
        type: List? (optional)
        item:
          object:
            name:
              type: String
            type:
              type: String
              allowed_values:
                - String
                - Int
                - Double
      localizations:
        type: Map
        key:
          description: Language code.
          type: String
        value:
          description: Localization value.
          type: String
```

[Example: general.json](example/bundles/general.json)

<details>
<summary><strong>Example Results</strong></summary>

##### iOS:
[GeneralLocalization.swift](example/results/ios/GeneralLocalization.swift)

[GeneralLocalization.xcstrings](example/results/ios/GeneralLocalization.xcstrings)

##### Flutter:
[general_localization.dart](example/results/flutter/general_localization.dart)

[general_localization_en.dart](example/results/flutter/general_localization_en.dart)

[general_localization_ua.dart](example/results/flutter/general_localization_ua.dart)

##### Android:
[values/general.xml](example/results/android/values/general.xml)

[values-ua/general.xml](example/results/android/values-ua/general.xml)

</details>
