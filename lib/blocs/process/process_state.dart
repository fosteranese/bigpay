part of 'process_bloc.dart';

sealed class ProcessState extends Equatable {
  const ProcessState({
    required this.event,
  });

  final ProcessEvent event;

  @override
  List<Object> get props => [event];
}

final class InitialProcess extends ProcessState {
  const InitialProcess({required super.event});
}

final class ExecutingProcess extends ProcessState {
  const ExecutingProcess({required super.event});
}

final class ProcessExecuted extends ProcessState {
  const ProcessExecuted({
    required super.event,
    required this.data,
  });

  final DataResponse data;

  @override
  List<Object> get props => [
    event,
    data,
  ];
}

final class ExecuteProcessError extends ProcessState {
  const ExecuteProcessError({
    required super.event,
    required this.error,
  });

  final DataError error;

  @override
  List<Object> get props => [
    event,
    error,
  ];
}
