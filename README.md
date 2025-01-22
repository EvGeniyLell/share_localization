## Share Localization

`share_localization` is a command-line tool that shares localization files 
for iOS, Flutter and Android projects. 
It ensures that localization strings are consistent across different languages and platforms.

Currently, it supports sharing `xcstrings`, `dart` and `xml` files.

### Attention: 
- Android part is not implemented yet.
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

### Settings options

The command-line tool expected find the `settings.json` file 
in the working directory.

Settings it is a json file formated like this:

```yaml
- languages:
    # List of languages what you want to share
    list:
      string: language code
- sources_folder:
    string: folder with localization files
# Custom options for each platform
# If you don't need to share some platform, just remove it from the settings
- ios:
    bundle_name:
      string: name of bundle
    destination_folder:
      # Generate files will be put here
      # support path back step with `../../`
      string: destination folder
- flutter:
    destination_folder:
      # Generate files will be put here
      # support path back step with `../../`
      string: destination folder
- android:
    destination_folder:
      # Generate files will be put here
      # support path back step with `../../`
      string: destination folder
```

[Example settings](example/Settings.json)


### Sources bundles

You should put your localization files in the folder with the name what you set in the settings.

#### Format of source localization files

```yaml
- languages:
    list:
      string: language code 
- keys:
    key:
      string: key of localization
    value:
      object:
      comment:
        string: comment for localization
      arguments:
        list:
          object:
            name:
              string: name of argument
            type:
              string: type of argument
              allowed types:
                String
                Int
                Double
      localizations:
        object:
          key:
            string: language code
          value:
            string: localization value
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

##### Android:
[General.swift](example/results/flutter/...)

[General.xcstrings](example/results/flutter/...)
</details>



