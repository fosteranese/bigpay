import 'package:flutter/material.dart' hide Action;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/data/models/response/response.md.dart';
import 'package:bigpay/models/actions/action.dart';

const _uuid = Uuid();

/// Dispatch helpers for the app-wide [ProcessBloc].
extension ProcessDispatch on BuildContext {
  /// Runs [action] on the [ProcessBloc] and returns the event that was
  /// dispatched — hand it straight to a [ProcessListener]/[ProcessBuilder]
  /// (`event: () => _event`) to correlate the result.
  ///
  /// Replaces the per-page ceremony of minting a UUID, building the event, and
  /// reading the bloc. The id is generated here, so each call is a distinct,
  /// correlatable request.
  ExecuteProcessEvent dispatchProcess(
    Action action, {
    bool saveActionPayload = false,
    bool saveActionResponse = false,
    bool returnSavedResponse = false,
    bool useSaveActionPayload = false,
  }) {
    final event = ExecuteProcessEvent(
      id: _uuid.v4(),
      action: action,
      saveActionPayload: saveActionPayload,
      saveActionResponse: saveActionResponse,
      returnSavedResponse: returnSavedResponse,
      useSaveActionPayload: useSaveActionPayload,
    );
    read<ProcessBloc>().add(event);
    return event;
  }
}

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
    this.message,
    this.error,
    this.isLoading = false,
    this.isCached = false,
    this.isSilent = false,
  });

  /// The parsed payload when the current state is a success, else null.
  final T? data;

  /// The server-supplied message on a success, else null. Useful for success
  /// dialogs/toasts that echo the backend's wording.
  final String? message;

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
ProcessSnapshot<T> _snapshotOf<T>(ProcessState state, ProcessEvent? event) {
  if (event == null || state.event != event) {
    return ProcessSnapshot<T>();
  }

  T? data;
  String? message;
  DataError? error;

  switch (state) {
    case ProcessExecuted():
      message = state.result.message;
      final payload = state.result.data;
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
    message: message,
    error: error,
    isLoading: state is ExecutingProcess,
    isCached: state.isCachedData,
    isSilent: state.isSilent,
  );
}

/// Rebuilds on every state belonging to the event returned by [event], with
/// the typed snapshot.
///
/// [event] is read live on each state change, so a page whose correlation event
/// is created lazily (e.g. on submit) can just return its current field —
/// `event: () => _mainEvent` — with no rebuild or `setState` required. Return
/// null while there is no event to watch yet; the snapshot is then empty.
class ProcessBuilder<T> extends StatelessWidget {
  const ProcessBuilder({
    super.key,
    required this.event,
    required this.builder,
  });

  final ValueGetter<ProcessEvent?> event;
  final Widget Function(BuildContext context, ProcessSnapshot<T> snapshot)
  builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProcessBloc, ProcessState>(
      buildWhen: (previous, current) => current.event == event(),
      builder: (context, state) => builder(
        context,
        _snapshotOf<T>(state, event()),
      ),
    );
  }
}

/// Runs [listener] for its side effects on every state belonging to the event
/// returned by [event], with the typed snapshot. Renders [child] unchanged.
///
/// Use for navigation, snackbars, dialogs — anything that should happen once
/// per state change rather than on every rebuild. See [ProcessBuilder] for how
/// [event] is read.
class ProcessListener<T> extends StatelessWidget {
  const ProcessListener({
    super.key,
    required this.event,
    required this.listener,
    required this.child,
  });

  final ValueGetter<ProcessEvent?> event;
  final void Function(BuildContext context, ProcessSnapshot<T> snapshot)
  listener;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProcessBloc, ProcessState>(
      listenWhen: (previous, current) => current.event == event(),
      listener: (context, state) => listener(
        context,
        _snapshotOf<T>(state, event()),
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

  final ValueGetter<ProcessEvent?> event;
  final void Function(BuildContext context, ProcessSnapshot<T> snapshot)
  listener;
  final Widget Function(BuildContext context, ProcessSnapshot<T> snapshot)
  builder;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProcessBloc, ProcessState>(
      listenWhen: (previous, current) => current.event == event(),
      listener: (context, state) => listener(
        context,
        _snapshotOf<T>(state, event()),
      ),
      buildWhen: (previous, current) => current.event == event(),
      builder: (context, state) => builder(
        context,
        _snapshotOf<T>(state, event()),
      ),
    );
  }
}

/// One entry in a [MultiProcessListener]: a watched event and its typed
/// side-effect callback — the config form of a single [ProcessListener].
class ProcessListenerConfig<T> {
  const ProcessListenerConfig({
    required this.event,
    required this.listener,
  });

  final ValueGetter<ProcessEvent?> event;
  final void Function(BuildContext context, ProcessSnapshot<T> snapshot)
  listener;

  // T is reified, so even when this config is held in a
  // `List<ProcessListenerConfig>` (T erased to dynamic at the list level) the
  // ProcessListener is built with the real T and the snapshot handed to
  // [listener] stays correctly typed.
  ProcessListener<T> _wrap(Widget child) => ProcessListener<T>(
    event: event,
    listener: listener,
    child: child,
  );
}

/// Nests one [ProcessListener] per entry over [child] — the transparent
/// analogue of `MultiBlocListener`. Use when a screen reacts to several
/// correlation events (e.g. a submit and a resend) instead of hand-nesting.
///
/// Each entry keeps its own type, so `snapshot.data` stays typed per listener.
class MultiProcessListener extends StatelessWidget {
  const MultiProcessListener({
    super.key,
    required this.listeners,
    required this.child,
  });

  final List<ProcessListenerConfig> listeners;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var tree = child;
    // Reversed so the first entry ends up outermost, preserving list order.
    for (final config in listeners.reversed) {
      tree = config._wrap(tree);
    }
    return tree;
  }
}

/// Read-side handle passed to [MultiProcessBuilder]'s builder: fetches the
/// latest typed snapshot seen for one of the watched events.
class ProcessSnapshots {
  const ProcessSnapshots._(this._lastByEvent);

  final Map<ProcessEvent, ProcessState> _lastByEvent;

  /// The most recent snapshot observed for [event], or an empty snapshot if it
  /// hasn't produced a state yet. [T] is supplied per call, so each read is
  /// typed independently.
  ProcessSnapshot<T> of<T>(ProcessEvent? event) {
    if (event == null) return ProcessSnapshot<T>();
    final state = _lastByEvent[event];
    if (state == null) return ProcessSnapshot<T>();
    return _snapshotOf<T>(state, event);
  }
}

/// Rebuilds when any of the [events] produces a new state, handing the builder
/// a [ProcessSnapshots] to read each one's latest typed snapshot.
///
/// Unlike a single [ProcessBuilder], this **accumulates**: it remembers the
/// last state per watched event, so results from several concurrent processes
/// can be shown together even though [ProcessBloc] only ever holds one current
/// state. [events] are read live, like [ProcessBuilder.event].
class MultiProcessBuilder extends StatefulWidget {
  const MultiProcessBuilder({
    super.key,
    required this.events,
    required this.builder,
  });

  final List<ValueGetter<ProcessEvent?>> events;
  final Widget Function(BuildContext context, ProcessSnapshots snapshots)
  builder;

  @override
  State<MultiProcessBuilder> createState() => _MultiProcessBuilderState();
}

class _MultiProcessBuilderState extends State<MultiProcessBuilder> {
  final Map<ProcessEvent, ProcessState> _lastByEvent = {};

  bool _isWatched(ProcessEvent event) =>
      widget.events.any((getEvent) => getEvent() == event);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProcessBloc, ProcessState>(
      listenWhen: (previous, current) => _isWatched(current.event),
      listener: (context, state) =>
          setState(() => _lastByEvent[state.event] = state),
      child: Builder(
        builder: (context) =>
            widget.builder(context, ProcessSnapshots._(_lastByEvent)),
      ),
    );
  }
}
