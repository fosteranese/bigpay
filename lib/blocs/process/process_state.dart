part of 'process_bloc.dart';

sealed class ProcessState extends Equatable {
  const ProcessState({
    required this.event,
    this.isCachedData = false,
  });

  final ProcessEvent event;
  final bool isCachedData;

  @override
  List<Object> get props => [
    event,
    isCachedData,
  ];
}

final class InitialProcess extends ProcessState {
  const InitialProcess({
    required super.event,
  });
}

final class ExecutingProcess extends ProcessState {
  const ExecutingProcess({
    required super.event,
    required super.isCachedData,
  });

  @override
  List<Object> get props => [
    event,
    isCachedData,
  ];
}

final class ProcessExecuted extends ProcessState {
  const ProcessExecuted({
    required super.event,
    required this.data,
    required super.isCachedData,
  });

  final DataResponse data;

  @override
  List<Object> get props => [
    event,
    data,
    isCachedData,
  ];
}

final class ExecuteProcessError extends ProcessState {
  const ExecuteProcessError({
    required super.event,
    required this.error,
    required super.isCachedData,
  });

  final DataError error;

  @override
  List<Object> get props => [
    event,
    error,
    isCachedData,
  ];
}
