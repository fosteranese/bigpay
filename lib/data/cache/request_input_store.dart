import 'package:bigpay/models/actions/action.dart';

/// Remembers the most recent action sent to each endpoint, so a later request
/// can reuse the last one's inputs.
///
/// Like [ResponseCache] it lives outside [ProcessBloc] and is injected into it,
/// so the last action for an endpoint can be read from anywhere — to retry a
/// failed request, or resume a flow with what was last submitted. Hold a single
/// instance (see `AppState.store`) so every caller shares it.
///
/// In-memory only, and deliberately so: an action's payload can carry
/// credentials (PINs, phone numbers), so unlike a cached response it is never
/// written to disk. It lives for the session and is gone on restart.
class RequestInputStore {
  final Map<String, Action> _inputs = {};

  /// The saved action for [endpoint], or null if none was saved this session.
  Action? read(String endpoint) => _inputs[endpoint];

  /// Records [action] as the latest input for its endpoint.
  ///
  /// The endpoint is the sole key — one saved action per endpoint, always
  /// derived from the action so it can never be stored under a mismatched key.
  void write(Action action) {
    _inputs[action.endpoint] = action;
  }

  /// Forgets the stored action for [endpoint].
  void remove(String endpoint) => _inputs.remove(endpoint);

  /// Forgets every stored action — e.g. on logout.
  void clear() => _inputs.clear();
}
