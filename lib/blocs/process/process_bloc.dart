import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/utils/remote.util.dart';
import 'package:bigpay/utils/response.util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'process_event.dart';
part 'process_state.dart';

class ProcessBloc extends Bloc<ProcessEvent, ProcessState> {
  ProcessBloc() : super(const InitialProcess(event: ZeroProcessEvent())) {
    on(_onExecuteProcess);
  }

  Future<void> _onExecuteProcess(
    ExecuteProcessEvent event,
    Emitter<ProcessState> emit,
  ) async {
    try {
      emit(ExecutingProcess(event: event));

      final data = await RemoteUtil.makeCall(event.action);

      emit(ProcessExecuted(event: event, data: data));
    } catch (ex) {
      emit(
        ExecuteProcessError(event: event, error: ResponseUtil.mapException(ex)),
      );
    }
  }
}
