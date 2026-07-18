import 'package:bigpay/data/cache/request_input_store.dart';
import 'package:bigpay/data/cache/response_cache.dart';
import 'package:bigpay/data/database/db.dart';

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
