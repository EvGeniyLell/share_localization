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

```json
{
  // List of languages waht you want to share
  "languages": [
    "en",
    "ua"
  ],
  // Folder with localization files
  "sources_folder": "Bundles",
  // Custom options for each platform
  // If you don't need to share some platform, just remove it from the settings
  "ios": {
    "bundle_name": "sdkResource",
    "destination_folder": "../../iOS-SDK/Translations"
  },
  "flutter": {
    "destination_folder": "../../Flutter-SDK/lib/src/translations"
  },
  "android": {
    "destination_folder": "android"
  }
}
```
### Sources bundles

You should put your localization files in the folder with the name what you set in the settings.
Format of source localization you can see below

```json
{
  "languages": [
    "en",
    "ua"
  ],
  "keys": {
    "file_size_error_body": {
      "comment": "This a body of error notification message.",
      "arguments": [
        {
          "name": "file_name",
          "type": "String"
        },
        {
          "name": "current_size",
          "type": "Double"
        },
        {
          "name": "maximum_size",
          "type": "Double"
        }
      ],
      "localizations": {
        "en": "The {file_name} has size {current_size}, it is biggest then maximum {maximum_size}.",
        "ua": "Цей {file_name} має розмір {current_size}, це більш ніж дозволений максимум {maximum_size}."
      }
    },
    "file_size_attention": {
      "comment": "This is a attention message for file size.",
      "arguments": [
        {
          "name": "maximum_size",
          "type": "Int"
        }
      ],
      "localizations": {
        "en": "File should be less or equal to {maximum_size} MB.",
        "ua": "Файл повинен бути меншим або рівним {maximum_size} МБ."
      }
    },
    "file_size_title": {
      "comment": "This is a title for file size error screen",
      "localizations": {
        "en": "Attention! The file size is too big.",
        "ua": "Увага! Розмір файлу занадто великий."
      }
    }
  },
  "version": "1.0"
}
```

result will be:

```swift
class GeneralLocalisation {
  private static func l(_ key: String.LocalizationValue) -> String {
    return String(localized: key, table: "General", bundle: .sdkResource)
  }
  
  /// This a body of error notification message.
  ///
  /// In en, this message translates to:
  /// **'The {file_name} has size {current_size}, it is biggest then maximum {maximum_size}.'**
  static func fileSizeErrorBody(_ fileName: String, _ currentSize: Double, _ maximumSize: Double) -> String {
    l("fileSizeErrorBody\(fileName)\(currentSize)\(maximumSize)")
  }

  /// This is a attention message for file size.
  ///
  /// In en, this message translates to:
  /// **'File should be less or equal to {maximum_size} MB.'**
  static func fileSizeAttention(_ maximumSize: Int) -> String {
    l("fileSizeAttention\(maximumSize)")
  }

  /// This is a title for file size error screen
  ///
  /// In en, this message translates to:
  /// **'Attention! The file size is too big.'**
  static var fileSizeTitle : String {
    l("fileSizeTitle")
  }  
}
```

and

```xcstrings
{
  "sourceLanguage" : "en",
  "strings" : {
    "fileSizeErrorBody%@%lf%lf" : {
      "comment" : "This a body of error notification message.",
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "The %1$@ has size %2$lf, it is biggest then maximum %3$lf."
          }
        },
        "ua" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Цей %1$@ має розмір %2$lf, це більш ніж дозволений максимум %3$lf."
          }
        }
      }
    },
    "fileSizeAttention%lld" : {
      "comment" : "This is a attention message for file size.",
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "File should be less or equal to %1$lld MB."
          }
        },
        "ua" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Файл повинен бути меншим або рівним %1$lld МБ."
          }
        }
      }
    },
    "fileSizeTitle" : {
      "comment" : "This is a title for file size error screen",
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Attention! The file size is too big."
          }
        },
        "ua" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Увага! Розмір файлу занадто великий."
          }
        }
      }
    }
  },
  "version" : "1.0"
}
```

