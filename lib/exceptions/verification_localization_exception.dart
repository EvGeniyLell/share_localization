import 'package:share_localization/exceptions/app_exception.dart';

class VerificationLocalizationException implements AppException {
  final String message;

  const VerificationLocalizationException(this.message);

  factory VerificationLocalizationException.missingLanguage({
    required String language,
    required String sourceName,
  }) = VerificationLocalizationMissingLanguageException;

  factory VerificationLocalizationException.missingTranslation({
    required String key,
    required String language,
    required String sourceName,
  }) = VerificationLocalizationMissingTranslationException;

  factory VerificationLocalizationException.extraArgument({
    required String argument,
    required String key,
    required String language,
    required String sourceName,
  }) = VerificationLocalizationExtraArgumentException;

  factory VerificationLocalizationException.missingArgument({
    required String argument,
    required String key,
    required String language,
    required String sourceName,
  }) = VerificationLocalizationMissingArgumentException;

  @override
  String toString() {
    return '$VerificationLocalizationException: $message';
  }
}

class VerificationLocalizationMissingLanguageException
    extends VerificationLocalizationException {
  final String language;
  final String sourceName;

  VerificationLocalizationMissingLanguageException({
    required this.language,
    required this.sourceName,
  }) : super(
          'Missing language ${language.toUpperCase()}'
          ' in $sourceName source',
        );
}

class VerificationLocalizationMissingTranslationException
    extends VerificationLocalizationException {
  final String key;
  final String language;
  final String sourceName;

  VerificationLocalizationMissingTranslationException({
    required this.key,
    required this.language,
    required this.sourceName,
  }) : super(
          'Missing translation for key "$key"'
          ' in ${language.toUpperCase()} $sourceName',
        );
}

class VerificationLocalizationExtraArgumentException
    extends VerificationLocalizationException {
  final String argument;
  final String key;
  final String language;
  final String sourceName;

  VerificationLocalizationExtraArgumentException({
    required this.argument,
    required this.key,
    required this.language,
    required this.sourceName,
  }) : super(
          'Extra argument "$argument" for key "$key"'
          ' in ${language.toUpperCase()} $sourceName',
        );
}

class VerificationLocalizationMissingArgumentException
    extends VerificationLocalizationException {
  final String argument;
  final String key;
  final String language;
  final String sourceName;

  VerificationLocalizationMissingArgumentException({
    required this.argument,
    required this.key,
    required this.language,
    required this.sourceName,
  }) : super(
          'Missing argument "$argument" for key "$key"'
          ' in ${language.toUpperCase()} $sourceName',
        );
}
