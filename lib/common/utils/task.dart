import 'dart:async';

import 'package:share_localization/common/utils/printer.dart';
import 'package:share_localization/common/utils/task_result.dart' as task;
import 'package:share_localization/common/exceptions/app_exception.dart';
import 'package:share_localization/common/exceptions/unexpected_exception.dart';

typedef TaskResult<T> = task.TaskResult<T, AppException>;
typedef TaskSucceeded<T> = task.TaskSucceeded<T, AppException>;
typedef TaskFailed<T> = task.TaskFailed<T, AppException>;
typedef Task<T> = Future<TaskResult<T>>;

Task<T> runAppTaskSafely<T>(
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
