part of 'process_bloc.dart';

sealed class ProcessEvent extends Equatable {
  const ProcessEvent({
    required this.id,
    this.saveActionPayload = false,
    this.saveActionResponse = false,
    this.returnSavedResponse = false,
    this.useSaveActionPayload = false,
  });

  final String id;
  final bool saveActionPayload;
  final bool saveActionResponse;
  final bool returnSavedResponse;
  final bool useSaveActionPayload;

  @override
  List<Object> get props => [
    id,
    saveActionPayload,
    saveActionResponse,
    returnSavedResponse,
    useSaveActionPayload,
  ];
}

final class ZeroProcessEvent extends ProcessEvent {
  const ZeroProcessEvent({super.id = ''});
}

final class ExecuteProcessEvent extends ProcessEvent {
  const ExecuteProcessEvent({
    required super.id,
    required this.action,
    super.saveActionPayload = false,
    super.saveActionResponse = false,
    super.returnSavedResponse = false,
    super.useSaveActionPayload = false,
  });

  final Action action;

  @override
  List<Object> get props => [
    id,
    action,
    saveActionPayload,
    saveActionResponse,
    returnSavedResponse,
    useSaveActionPayload,
  ];
}
