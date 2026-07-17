part of 'process_bloc.dart';

sealed class ProcessState extends Equatable {
  const ProcessState({
    required this.event,
    this.isCachedData = false,
    this.isSilent = false,
  });

  final ProcessEvent event;
  final bool isCachedData;
  final bool isSilent;

  @override
  List<Object> get props => [
    event,
    isCachedData,
    isSilent,
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
    required super.isSilent,
  });

  @override
  List<Object> get props => [
    event,
    isCachedData,
    isSilent,
  ];
}

final class ProcessExecuted extends ProcessState {
  const ProcessExecuted({
    required super.event,
    required this.data,
    required super.isCachedData,
    required super.isSilent,
  });

  final DataResponse data;

  @override
  List<Object> get props => [
    event,
    data,
    isCachedData,
    isSilent,
  ];
}

final class ExecuteProcessError extends ProcessState {
  const ExecuteProcessError({
    required super.event,
    required this.error,
    required super.isCachedData,
    required super.isSilent,
  });

  final DataError error;

  @override
  List<Object> get props => [
    event,
    error,
    isCachedData,
    isSilent,
  ];
}
