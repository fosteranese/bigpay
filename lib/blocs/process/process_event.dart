part of 'process_bloc.dart';

sealed class ProcessEvent extends Equatable {
  const ProcessEvent({
    required this.id,
  });

  final String id;

  @override
  List<Object> get props => [id];
}

final class ZeroProcessEvent extends ProcessEvent {
  const ZeroProcessEvent({super.id = ''});
}

final class ExecuteProcessEvent extends ProcessEvent {
  const ExecuteProcessEvent({
    required super.id,
    required this.action,
  });

  final Action action;

  @override
  List<Object> get props => [
    id,
    action,
  ];
}
