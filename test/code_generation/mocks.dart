library;

import 'package:mocktail/mocktail.dart';
import 'package:share_localization/code_generation/code_generation.dart';
import 'package:share_localization/code_generation/use_cases/code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/flutter/flutter_code_generation_use_case.dart';
import 'package:share_localization/code_generation/use_cases/ios/ios_code_generation_use_case.dart';

export 'package:share_localization/code_generation/code_generation.dart';

class MockCodeGenerationUseCase extends Mock implements CodeGenerationUseCase {}

class MockBatchCodeGenerationUseCase extends Mock
    implements BatchCodeGenerationUseCase {}

class MockFlutterCodeGenerationUseCase extends Mock
    implements FlutterCodeGenerationUseCase {}

class MockBuildIosLocalizationUseCase extends Mock
    implements IosCodeGenerationUseCase {}
