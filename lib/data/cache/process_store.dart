import 'package:bigpay/data/cache/request_input_store.dart';
import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/database/db.dart';

/// The stores [ProcessBloc] depends on, bundled behind one object.
///
/// [cache] holds action responses (memory over the encrypted box); [inputs]
/// holds the last request per endpoint (memory only). Grouping them lets the
/// bloc take a single dependency, and gives outside callers one entry point —
/// hold a single instance (see `AppState.store`) so everyone shares the same
/// tiers.
class ProcessStore {
  ProcessStore({
    required this.cache,
    required this.inputs,
  });

  /// Builds both stores over one [Database].
  ProcessStore.of(Database db)
    : cache = ResponseCache(db),
      inputs = RequestInputStore();

  final ResponseCache cache;
  final RequestInputStore inputs;
}
