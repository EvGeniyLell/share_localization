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

### Settings Options

The command-line tool expects to find the `settings.json` file in the working directory.

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
        Optional flag to use camelCase for keys and file names.
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
[General.swift](example/results/ios/General.swift)

[General.xcstrings](example/results/ios/General.xcstrings)

##### Flutter:
[general.dart](example/results/flutter/general.dart)

[general_en.dart](example/results/flutter/general_en.dart)

[general_ua.dart](example/results/flutter/general_ua.dart)

##### Android:
[general_en.xml](example/results/android/general_en.xml)

[general_ua.xml](example/results/android/general_ua.xml)

</details>
