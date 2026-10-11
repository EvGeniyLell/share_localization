import 'package:mocktail/mocktail.dart';

import '../common/mocks.dart';

/// Makes [fileService] (a [MockFileService]) record every `createFile` call
/// into [virtualFiles] instead of writing to disk.
void setUpMockFileService(
  FileService fileService,
  List<InvocationCreateFile> virtualFiles,
) {
  when(() {
    return fileService.createFile(
      path: any(named: 'path'),
      content: any(named: 'content'),
    );
  }).thenAnswer((invocation) async {
    virtualFiles.add(InvocationCreateFile(invocation));
  });
}
