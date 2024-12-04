sealed class TaskResult<R, E> {
  const TaskResult();

  bool get succeeded => this is TaskSucceeded<R, E>;

  R get data => throw Exception('Task is not succeeded');

  bool get failed => this is TaskFailed<R, E>;

  E get exception => throw Exception('Task is not failed');
}

class TaskSucceeded<R, E> extends TaskResult<R, E> {
  @override
  final R data;

  const TaskSucceeded(this.data);
}

class TaskFailed<R, E> extends TaskResult<R, E> {
  @override
  final E exception;

  const TaskFailed(this.exception);
}


