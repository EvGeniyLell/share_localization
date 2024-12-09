import 'package:share_localisation/exceptions/app_exception.dart';

class VerificationLocalisationException implements AppException {
  final String message;

  const VerificationLocalisationException(this.message);

  factory VerificationLocalisationException.missingLanguage({
    required String language,
    required String sourceName,
  }) = VerificationLocalisationMissingLanguageException;

  factory VerificationLocalisationException.missingTranslation({
    required String key,
    required String language,
    required String sourceName,
  }) = VerificationLocalisationMissingTranslationException;

  factory VerificationLocalisationException.extraArgument({
    required String argument,
    required String key,
    required String language,
    required String sourceName,
  }) = VerificationLocalisationExtraArgumentException;

  factory VerificationLocalisationException.missingArgument({
    required String argument,
    required String key,
    required String language,
    required String sourceName,
  }) = VerificationLocalisationMissingArgumentException;

  @override
  String toString() {
    return '$VerificationLocalisationException: $message';
  }
}

class VerificationLocalisationMissingLanguageException
    extends VerificationLocalisationException {
  final String language;
  final String sourceName;

  VerificationLocalisationMissingLanguageException({
    required this.language,
    required this.sourceName,
  }) : super(
          'Missing language ${language.toUpperCase()}'
          ' in $sourceName source',
        );
}

class VerificationLocalisationMissingTranslationException
    extends VerificationLocalisationException {
  final String key;
  final String language;
  final String sourceName;

  VerificationLocalisationMissingTranslationException({
    required this.key,
    required this.language,
    required this.sourceName,
  }) : super(
          'Missing translation for key "$key"'
          ' in ${language.toUpperCase()} $sourceName',
        );
}

class VerificationLocalisationExtraArgumentException
    extends VerificationLocalisationException {
  final String argument;
  final String key;
  final String language;
  final String sourceName;

  VerificationLocalisationExtraArgumentException({
    required this.argument,
    required this.key,
    required this.language,
    required this.sourceName,
  }) : super(
          'Extra argument "$argument" for key "$key"'
          ' in ${language.toUpperCase()} $sourceName',
        );
}

class VerificationLocalisationMissingArgumentException
    extends VerificationLocalisationException {
  final String argument;
  final String key;
  final String language;
  final String sourceName;

  VerificationLocalisationMissingArgumentException({
    required this.argument,
    required this.key,
    required this.language,
    required this.sourceName,
  }) : super(
          'Missing argument "$argument" for key "$key"'
          ' in ${language.toUpperCase()} $sourceName',
        );
}
