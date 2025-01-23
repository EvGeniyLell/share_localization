## Share Localization

`share_localization` is a command-line tool that shares localization files for iOS, Flutter, and Android projects. It ensures that localization strings are consistent across different languages and platforms.

Currently, it supports sharing `xcstrings`, `dart`, and `xml` files.

### Attention:
- The Android part is not implemented yet.
- This tool is still in development and may not work as expected.

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

### Settings Options

The command-line tool expects to find the `settings.json` file in the working directory.

The settings file should be formatted as follows:

```yaml
languages:
  # List of languages you want to share
  # First language will be used for descriptions
  list:
    string: language_code
sources_folder:
  # Folder with localization files
  string: folder_with_localization_files
# Custom options for each platform
# If you don't need to share some platform, just remove it from the settings
ios:
  bundle_name:
    string: name_of_bundle
  destination_folder:
    # Generated files will be put here
    # Supports path back step with `../../`
    string: destination_folder
flutter:
  destination_folder:
    # Generated files will be put here
    # Supports path back step with `../../`
    string: destination_folder
android:
  destination_folder:
    # Generated files will be put here
    # Supports path back step with `../../`
    string: destination_folder
```

[Example settings](example/settings.json)

### Source Bundles

You should put your localization files in the folder with the name specified in the settings.

#### Format of Source Localization Files

```yaml
languages:
  list:
    string: language_code
keys:
  key:
    string: key_of_localization
  value:
    object:
    comment:
      string: comment_for_localization
    arguments:
      list:
        object:
          name:
            string: name_of_argument
          type:
            enum: type_of_argument
            allowed_values:
              - String
              - Int
              - Double
    localizations:
      list:
        object:
          key:
            string: language_code
          value:
            string: localization_value
```

[Example: general.json](example/bundles/general.json)

<details>
<summary><strong>Example Results</strong></summary>

##### iOS:
[General.swift](example/results/ios/General.swift)

[General.xcstrings](example/results/ios/General.xcstrings)

##### Flutter:
[general.dart](example/results/flutter/general.dart)

[general_en.dart](example/results/flutter/general_en.dart)

##### Android: not implemented yet
[General.swift](example/results/flutter/...)

[General.xcstrings](example/results/flutter/...)
</details>