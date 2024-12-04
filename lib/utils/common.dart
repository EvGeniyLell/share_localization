import 'dart:async';

import 'package:share_localisation/exceptions/app_exception.dart';
import 'package:share_localisation/exceptions/unexpected_exception.dart';
import 'package:share_localisation/utils/printer.dart';
import 'package:share_localisation/utils/task_result.dart' as task;

// --- AppTask ---
typedef TaskResult<T> = task.TaskResult<T, AppException>;
typedef TaskSucceeded<T> = task.TaskSucceeded<T, AppException>;
typedef TaskFailed<T> = task.TaskFailed<T, AppException>;
typedef AppTask<T> = Future<TaskResult<T>>;

AppTask<T> runAppTaskSafely<T>(
  FutureOr<T> Function() block,
) async {
  try {
    final T result = await block();
    return TaskSucceeded<T>(result);
  } on Object catch (error, stackTrace) {
    Printer().logError(error, stackTrace: stackTrace);
    if (error is AppException) {
      return TaskFailed<T>(error);
    } else {
      return TaskFailed<T>(
        UnexpectedException(error.toString()),
      );
    }
  }
}

// --- Json ---
typedef JsonMap = Map<String, Object?>;

// --- List ---
extension AppListExtension on List {
  bool equals(List list) {
    if (length != list.length) return false;
    return every((item) => list.contains(item));
  }
}
