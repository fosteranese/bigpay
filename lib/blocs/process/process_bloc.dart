import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bigpay/constants/response.const.dart';
import 'package:bigpay/constants/status.const.dart';
import 'package:bigpay/data/cache/process_store.dart';
import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/utils/remote.util.dart';
import 'package:bigpay/utils/response.util.dart';

part 'process_event.dart';
part 'process_state.dart';

class ProcessBloc extends Bloc<ProcessEvent, ProcessState> {
  ProcessBloc({
    required this.store,
  }) : super(const InitialProcess(event: ZeroProcessEvent())) {
    on<ExecuteProcessEvent>(_onExecuteProcess);
  }

  final ProcessStore store;

  /// Applies the action's parser to a raw envelope, turning cached or freshly
  /// fetched JSON into the action's typed result. Runs on every path so cache
  /// and network produce identical, typed [ProcessExecuted] data.
  DataResponse _parsed(Action action, DataResponse raw) {
    final parse = action.responseDataFunc;
    return DataResponse(
      code: raw.code,
      status: raw.status,
      message: raw.message,
      data: parse != null ? parse(raw.data) : raw.data,
      imageBaseUrl: raw.imageBaseUrl,
      imageDirectory: raw.imageDirectory,
      timeStamp: raw.timeStamp,
    );
  }

  Future<void> _onExecuteProcess(
    ExecuteProcessEvent event,
    Emitter<ProcessState> emit,
  ) async {
    bool isSilent = false;

    var action = event.action;
    if (event.useSaveActionPayload) {
      final saved = store.inputs.read(event.action.endpoint);
      if (saved == null) {
        emit(
          ExecuteProcessError(
            event: event,
            error: GeneralResponseConst.absentPayload,
            isCachedData: false,
            isSilent: isSilent,
          ),
        );
        return;
      }
      action = event.action.copyWith(payload: saved.payload);
    }

    final cacheKey = ResponseCache.keyFor(action);
    try {
      final cached = event.returnSavedResponse
          ? await store.cache.read(cacheKey)
          : null;

      if (cached != null) {
        emit(
          ProcessExecuted(
            event: event,
            result: _parsed(action, cached),
            isCachedData: true,
            isSilent: false,
          ),
        );
        isSilent = true;
        emit(
          ExecutingProcess(
            event: event,
            isCachedData: true,
            isSilent: isSilent,
          ),
        );
      } else {
        emit(
          ExecutingProcess(
            event: event,
            isCachedData: false,
            isSilent: isSilent,
          ),
        );
      }

      if (event.saveActionPayload) {
        store.inputs.write(event.action);
      }

      final response = event.action.noRemoteFunc == null
          ? await RemoteUtil.makeCall(action)
          : event.action.noRemoteFunc?.call(event.action.payload);

      if (event.saveActionResponse &&
          response!.status == StatusConstants.success) {
        store.cache.write(cacheKey, response, endpoint: action.endpoint);
      }

      emit(
        ProcessExecuted(
          event: event,
          result: _parsed(action, response!),
          isCachedData: false,
          isSilent: isSilent,
        ),
      );
    } catch (ex) {
      emit(
        ExecuteProcessError(
          event: event,
          error: ResponseUtil.mapException(ex),
          isCachedData: false,
          isSilent: isSilent,
        ),
      );
    }
  }
}
