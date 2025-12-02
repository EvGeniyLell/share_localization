library;

import 'package:mocktail/mocktail.dart';
import 'package:share_localization/common/common.dart';

export 'package:share_localization/common/common.dart';

class MockFileService extends Mock implements FileService {}

extension InvocationTestExtension on Invocation {
  T arg<T>(String key) => namedArguments[Symbol(key)] as T;
}

class InvocationCreateFile {
  final String path;
  final String content;

  InvocationCreateFile(Invocation invocation)
    : path = _fixPath(invocation.arg('path')),
      content = invocation.arg('content');

  static String _fixPath(String path) {
    final d = FileServiceHelper.getCurrentDirectory().path.split('/');
    final p = FileServiceHelper.getCurrentPath(path).split('/');
    while (d.isNotEmpty && p.isNotEmpty && d.first == p.first) {
      p.removeAt(0);
      d.removeAt(0);
    }
    return p.join('/');
  }

  @override
  String toString() {
    return '\n'
        '-------------------------------------------------------------\n'
        '$path\n'
        '-------------------------------------------------------------\n'
        '$content\n'
        '-------------------------------------------------------------\n';
  }
}

extension ContentExtension on String {
  String tremContent() {
    final lines = split('\n').map((e) => e.trim()).toList();
    while (lines.isNotEmpty && lines.last.isEmpty) {
      lines.removeLast();
    }
    while (lines.isNotEmpty && lines.first.isEmpty) {
      lines.removeAt(0);
    }
    return lines.join('\n');
  }
}
