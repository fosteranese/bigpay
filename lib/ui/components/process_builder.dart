import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/response/response.md.dart';

/// One event's current state in [ProcessBloc], typed.
///
/// Reflects the state that triggered this callback — not an accumulated view.
/// [data] is non-null only while the current state is a success for the event,
/// [error] only while it is a failure; a loading transition carries neither.
/// A widget that needs to keep showing the last result during a refresh should
/// retain it itself (`snapshot.data ?? _held`).
class ProcessSnapshot<T> {
  const ProcessSnapshot({
    this.data,
    this.error,
    this.isLoading = false,
    this.isCached = false,
    this.isSilent = false,
  });

  /// The parsed payload when the current state is a success, else null.
  final T? data;

  /// The failure when the current state is an error, else null.
  final DataError? error;

  /// A request for this event is in flight.
  final bool isLoading;

  /// The current result came from the on-device cache, not the network.
  final bool isCached;

  /// The background half of a cache-then-refresh: a result is already on screen
  /// and the network refresh is running behind it. Side effects (navigation,
  /// snackbars) usually want to skip these to avoid firing twice per event.
  final bool isSilent;

  bool get hasData => data != null;
  bool get hasError => error != null;
}

/// Projects the raw [ProcessBloc] state onto [event], typed.
///
/// [ProcessBloc] streams every action through one state type, so a consumer
/// must (1) match the state to the event it came from, (2) not trust the
/// state until that match is confirmed — `buildWhen`/`listenWhen` gate the
/// callback but not the state handed to a first build, and (3) cast the erased
/// `DataResponse.data`. This does all three; the widgets below are thin
/// wrappers over it.
ProcessSnapshot<T> _snapshotOf<T>(ProcessState state, ProcessEvent event) {
  if (state.event != event) {
    return ProcessSnapshot<T>();
  }

  T? data;
  DataError? error;

  switch (state) {
    case ProcessExecuted():
      final payload = state.data.data;
      // A type mismatch means the Action's responseDataFunc and this T
      // disagree; drop it rather than throw inside a build/listener.
      if (payload is T) {
        data = payload;
      }
    case ExecuteProcessError():
      error = state.error;
    case ExecutingProcess():
    case InitialProcess():
      break;
  }

  return ProcessSnapshot<T>(
    data: data,
    error: error,
    isLoading: state is ExecutingProcess,
    isCached: state.isCachedData,
    isSilent: state.isSilent,
  );
}

/// Rebuilds on every state belonging to [event], with the typed snapshot.
///
/// [event] must be a stable instance — a [ProcessEvent]'s `props` include a
/// random id, so two inline-built events never compare equal. Hold it in a
/// field or a top-level final, as `startUpEvent` is.
class ProcessBuilder<T> extends StatelessWidget {
  const ProcessBuilder({
    super.key,
    required this.event,
    required this.builder,
  });

  final ProcessEvent event;
  final Widget Function(BuildContext context, ProcessSnapshot<T> snapshot)
  builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProcessBloc, ProcessState>(
      buildWhen: (previous, current) => current.event == event,
      builder: (context, state) => builder(
        context,
        _snapshotOf<T>(state, event),
      ),
    );
  }
}

/// Runs [listener] for its side effects on every state belonging to [event],
/// with the typed snapshot. Renders [child] unchanged.
///
/// Use for navigation, snackbars, dialogs — anything that should happen once
/// per state change rather than on every rebuild. See [ProcessBuilder] for the
/// [event] instance requirement.
class ProcessListener<T> extends StatelessWidget {
  const ProcessListener({
    super.key,
    required this.event,
    required this.listener,
    required this.child,
  });

  final ProcessEvent event;
  final void Function(BuildContext context, ProcessSnapshot<T> snapshot)
  listener;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProcessBloc, ProcessState>(
      listenWhen: (previous, current) => current.event == event,
      listener: (context, state) => listener(
        context,
        _snapshotOf<T>(state, event),
      ),
      child: child,
    );
  }
}

/// Both [ProcessListener] and [ProcessBuilder] over one [event]: side effects
/// from [listener], UI from [builder], each with the typed snapshot.
///
/// Reach for this when a screen both reacts to a result (navigate, toast) and
/// renders it. See [ProcessBuilder] for the [event] instance requirement.
class ProcessConsumer<T> extends StatelessWidget {
  const ProcessConsumer({
    super.key,
    required this.event,
    required this.listener,
    required this.builder,
  });

  final ProcessEvent event;
  final void Function(BuildContext context, ProcessSnapshot<T> snapshot)
  listener;
  final Widget Function(BuildContext context, ProcessSnapshot<T> snapshot)
  builder;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProcessBloc, ProcessState>(
      listenWhen: (previous, current) => current.event == event,
      listener: (context, state) => listener(
        context,
        _snapshotOf<T>(state, event),
      ),
      buildWhen: (previous, current) => current.event == event,
      builder: (context, state) => builder(
        context,
        _snapshotOf<T>(state, event),
      ),
    );
  }
}
