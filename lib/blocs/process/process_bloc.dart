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
    on<ExecuteProcessEvent>(_onExecuteProcess);
  }

  final Map<String, ActionPayloadSerializable> _processInputs = {};
  final Map<String, DataResponse> _processResponses = {};

  /// Identity of a cached response.
  ///
  /// The endpoint alone is not enough: two calls to the same endpoint with
  /// different inputs would share a key and serve each other's data, so the
  /// payload is part of the identity.
  static String _responseCacheKey(Action action) =>
      '${action.endpoint}:${action.payload.toJsonString()}';

  Future<void> _onExecuteProcess(
    ExecuteProcessEvent event,
    Emitter<ProcessState> emit,
  ) async {
    bool isCachedData = false;
    final cacheKey = _responseCacheKey(event.action);
    try {
      isCachedData =
          event.returnSavedResponse && _processResponses.containsKey(cacheKey);
      if (isCachedData) {
        emit(
          ProcessExecuted(
            event: event,
            data: _processResponses[cacheKey]!,
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
        // Cache the whole DataResponse — ProcessExecuted.data is a
        // DataResponse, so storing response.data (the inner value) here would
        // blow up on the cache-hit emit and lose the response metadata.
        _processResponses[cacheKey] = response;
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
