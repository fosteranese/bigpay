import 'package:bigpay/constants/status.const.dart';
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

  final Map<String, dynamic> _processInputs = {};
  final Map<String, dynamic> _processResponses = {};

  Future<void> _onExecuteProcess(
    ExecuteProcessEvent event,
    Emitter<ProcessState> emit,
  ) async {
    bool isCachedData = false;
    try {
      isCachedData =
          event.returnSavedResponse &&
          _processResponses.containsKey(event.action.endpoint);
      if (isCachedData) {
        emit(
          ProcessExecuted(
            event: event,
            data: _processResponses[event.action.endpoint],
            isCachedData: isCachedData,
          ),
        );
        emit(
          ExecutingProcess(
            event: event,
            isCachedData: isCachedData,
          ),
        );
      } else {
        emit(
          ExecutingProcess(
            event: event,
            isCachedData: isCachedData,
          ),
        );
      }

      if (event.saveActionPayload) {
        _processInputs[event.action.endpoint] = event.action.payload;
      }

      final response = await RemoteUtil.makeCall(event.action);

      if (event.saveActionResponse &&
          response.status == StatusConstants.success) {
        _processResponses[event.action.endpoint] = response.data;
      }

      emit(
        ProcessExecuted(
          event: event,
          data: response,
          isCachedData: isCachedData,
        ),
      );
    } catch (ex) {
      emit(
        ExecuteProcessError(
          event: event,
          error: ResponseUtil.mapException(ex),
          isCachedData: isCachedData,
        ),
      );
    }
  }
}
